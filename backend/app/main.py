# app/main.py
import logging
import os
import json
import tempfile
from contextlib import asynccontextmanager
from typing import Dict, List, Optional
import asyncio

from dotenv import load_dotenv
load_dotenv()

from fastapi import FastAPI, File, UploadFile, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from openai import OpenAI

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# ------------------------------------------------------
# OPENAI (tembel yükleme — /health OPENAI olmadan çalışır)
# ------------------------------------------------------
_openai: Optional[OpenAI] = None


def get_openai_client() -> OpenAI:
    global _openai
    if _openai is None:
        key = (os.getenv("OPENAI_API_KEY") or "").strip()
        if not key:
            raise HTTPException(
                status_code=503,
                detail="OpenAI is not configured (set OPENAI_API_KEY).",
            )
        _openai = OpenAI(api_key=key, timeout=300.0)
    return _openai


# ------------------------------------------------------
# LIFESPAN
# ------------------------------------------------------
@asynccontextmanager
async def lifespan(app: FastAPI):
    from app.database import init_db
    await init_db()
    yield


# ------------------------------------------------------
# FASTAPI APP
# ------------------------------------------------------
app = FastAPI(title="DeLeA Backend", lifespan=lifespan)

# CORS: CORS_ALLOW_ORIGINS="https://app.example.com,http://localhost:5000" veya "*" (geliştirme)
_cors = (os.getenv("CORS_ALLOW_ORIGINS") or "*").strip()
if _cors == "*":
    _cors_list = ["*"]
else:
    _cors_list = [o.strip() for o in _cors.split(",") if o.strip()]

app.add_middleware(
    CORSMiddleware,
    allow_origins=_cors_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

from app.routers import verify as verify_router
app.include_router(verify_router.router)


def is_too_short(text: str, min_words: int = 3) -> bool:
    if not text:
        return True
    return len(text.split()) < min_words


@app.get("/health")
async def health():
    """Backend erişilebilirlik testi."""
    return {"ok": True, "message": "Backend çalışıyor"}


def _clamp_score(value, min_v=0, max_v=100):
    try:
        v = float(value)
    except Exception:
        return 0
    if v < min_v:
        return min_v
    if v > max_v:
        return max_v
    return int(round(v))


def transcribe_tmp_path(tmp_path: str) -> str:
    """
    Transkript: env OPENAI_TRANSCRIBE_MODEL (yoksa whisper-1, geniş uyumluluk).
    Dil zorlama: OPENAI_TRANSCRIBE_LANG (ör. en, tr) sadece doluysa; aksi hâlde
    API otomatik tespit — language='en' sabit bazı cihaz/lisan koşullarında boş dönebiliyordu.
    """
    model = (os.getenv("OPENAI_TRANSCRIBE_MODEL") or "whisper-1").strip() or "whisper-1"
    lang = (os.getenv("OPENAI_TRANSCRIBE_LANG") or "").strip()
    try:
        fsize = os.path.getsize(tmp_path)
    except OSError:
        fsize = 0
    with open(tmp_path, "rb") as audio_f:
        kwargs: dict = {
            "model": model,
            "file": audio_f,
            "response_format": "json",
        }
        if len(lang) >= 2:
            kwargs["language"] = lang
        t = get_openai_client().audio.transcriptions.create(**kwargs)
    text = t.text.strip()
    if not text and fsize > 0:
        logger.warning(
            "Transkript boş (model=%s, %d byte); OPENAI_TRANSCRIBE_LANG veya ses kalitesi kontrol edin.",
            model,
            fsize,
        )
    return text


# ============================================================
# 1) SINAV SİMÜLASYONU /evaluate  (GENEL ENDPOINT)
# ============================================================
@app.post("/evaluate")
async def evaluate(
    file: UploadFile = File(...),
    question_id: Optional[str] = Form(None),
    question_type: Optional[str] = Form(None),
    question_text: Optional[str] = Form(None),
):
    """
    Sınav simülasyonu için ortak endpoint.
    """
    try:
        return await _do_evaluate(file, question_id, question_type, question_text)
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("[/evaluate] Beklenmeyen hata: %s", e)
        raise HTTPException(status_code=500, detail=f"Değerlendirme hatası: {str(e)}")


async def _do_evaluate(file, question_id, question_type, question_text):
    """Evaluate endpoint'in gerçek iş mantığı."""
    logger.info("[/evaluate] İstek alındı, dosya: %s", file.filename)

    # 1) Dosyayı geçici klasöre kaydet
    suffix = os.path.splitext(file.filename)[1] or ".wav"
    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
            tmp.write(await file.read())
            tmp_path = tmp.name
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Temp file error: {e}")

    # 2) Transkripsiyon
    logger.info("[/evaluate] OpenAI transcription başlatılıyor...")
    try:
        transcript = transcribe_tmp_path(tmp_path)
    finally:
        try:
            os.remove(tmp_path)
        except OSError:
            pass
    logger.info(
        "[/evaluate] Transcription tamam: %s...",
        (transcript[:50] + "..." if len(transcript) > 50 else transcript),
    )

    # Çok kısa ise otomatik 0 ve basic feedback
    if is_too_short(transcript, min_words=3):
        scores = {
            "fluency": 0,
            "grammar": 0,
            "vocabulary": 0,
            "overall": 0,
        }
        feedback = {
            "verilen_yanit": transcript or "(Hiç yanıt yok)",
            "grammar_errors": [
                "Cevap yok veya çok kısa olduğu için detaylı değerlendirme yapılamadı."
            ],
            "corrected_answer": "",
            "overall_comment": "Lütfen en az 2–3 cümlelik bir İngilizce yanıt ver.",
        }
        return {
            "question_id": question_id,
            "question_type": question_type,
            "question_text": question_text,
            "transcript": transcript,
            "scores": scores,
            "feedback": feedback,
            "meta": {
                "relevance_level": "off_topic",
                "relevance_comment": "Cevap yok veya çok kısa.",
            },
        }

    # -------------------------------------------------------
    # 3) ÖNCE: SORU–CEVAP UYUMUNU SINIFLANDIR
    # -------------------------------------------------------
    rel_system_msg = (
        "Sen THY DLA mülakatında soru-cevap uyumunu ölçen bir jüri üyesisin. "
        "Sadece JSON döndür."
    )

    rel_user_prompt = f"""
Aşağıda bir mülakat sorusu ve adayın cevabı var.

Soru:
\"\"\"{question_text or ""}\"\"\"


Adayın cevabı (transkript):
\"\"\"{transcript}\"\"\"


Cevabın SORUYLA ne kadar alakalı olduğunu değerlendir:

- Eğer aday soruyu açıkça cevaplıyor, gerekli açıklamaları yapıyorsa:
    relevance_level = "on_topic"
- Eğer cevap kısmen ilgili ama sorunun önemli kısımlarını atlıyorsa:
    relevance_level = "partially_on_topic"
- Eğer cevap tamamen alakasızsa, sadece selamlama/boş konuşma içeriyorsa
  (örn. "Hello, how are you?", "Everything is fine", "I like movies" vb.)
  ya da soruyu hiç cevaplamıyorsa:
    relevance_level = "off_topic"

SADECE şu JSON formatında cevap ver:

{{
  "relevance_level": "on_topic",
  "relevance_comment": "..."
}}
"""

    logger.info("[/evaluate] Relevance + scoring GPT çağrıları yapılıyor...")
    try:
        rel_chat = get_openai_client().chat.completions.create(
            model="gpt-4o-mini",
            response_format={"type": "json_object"},
            messages=[
                {"role": "system", "content": rel_system_msg},
                {"role": "user", "content": rel_user_prompt},
            ],
        )
        rel_raw = rel_chat.choices[0].message.content
        rel_data: Dict = json.loads(rel_raw)
        relevance_level = rel_data.get("relevance_level", "on_topic")
        relevance_comment = rel_data.get(
            "relevance_comment", "Soru-cevap uyumu normal görünüyor."
        )
    except Exception:
        # Bir problem olursa default: on_topic
        relevance_level = "on_topic"
        relevance_comment = "Uyum değerlendirmesi yapılamadı, varsayılan on_topic alındı."

    # -------------------------------------------------------
    # 4) PUAN + FEEDBACK (relevance'a göre iki ayrı yol)
    # -------------------------------------------------------
    system_msg = (
        "Sen THY DLA kabin mülakatında konuşma değerlendiren çok deneyimli "
        "bir İngilizce öğretmenisin. Sadece JSON cevap ver."
    )

    if relevance_level == "off_topic":
        # Tamamen alakasız cevap için özel prompt:
        user_prompt = f"""
Soru türü: {question_type or "-"}
Soru metni: \"\"\"{question_text or ""}\"\"\"

Adayın cevabı (transkript) SORUYLA ALAKALI DEĞİL:
\"\"\"{transcript}\"\"\"


Bu cevap selamlama/boş konuşma tarzında ve soruyu YANITLAMIYOR.

KURALLAR:

- Bu durumda overall puanı 0 ile 20 arasında ver.
- fluency, grammar ve vocabulary puanlarını 0 ile 40 arasında ver.
- Dil kalitesi iyi bile olsa bu sınırları ASLA aşma, çünkü soru cevaplanmadı.
- overall_comment içinde mutlaka cevabın soruyu cevaplamadığını açıkça söyle.

corrected_answer için:

- corrected_answer HER ZAMAN soruyu DOĞRUDAN cevaplayan,
  4–6 cümlelik İDEAL BİR MÜLAKAT CEVABI olsun.
- Adayın cevabını tamamen görmezden gel.
- Özellikle "Hello", "How are you?", "Thank you for asking" gibi selamlama cümleleri
  kullanma. Direkt soruyu cevaplayan içeriğe odaklan.
- Cevap gerçek bir adayın iş/staj tecrübesini anlatıyormuş gibi doğal ve detaylı olsun.

Görevin:

1) 0–100 arasında DÖRT skor üret (ama yukarıdaki sınırları dikkate al):
   - fluency
   - grammar
   - vocabulary
   - overall

2) 'feedback' alanında:
   - verilen_yanit: Adayın cevabını (transcript) mümkün olduğunca aynen yaz.
   - grammar_errors: Önemli gramer hatalarını TÜRKÇE kısa açıklamalarla liste halinde yaz
     (en fazla 5 madde, hiç hata yoksa ["Belirgin bir gramer hatası yok."] yaz).
   - corrected_answer: Soruyu TAM olarak cevaplayan, 4–6 cümlelik İNGİLİZCE örnek bir mülakat cevabı.
   - overall_comment: Genel TÜRKÇE değerlendirme (2–4 cümle), özellikle
     cevabın soruyla alakasız olduğunu belirt.

SADECE şu JSON formatında cevap ver:

{{
  "scores": {{
    "fluency": 0,
    "grammar": 0,
    "vocabulary": 0,
    "overall": 0
  }},
  "feedback": {{
    "verilen_yanit": "...",
    "grammar_errors": ["..."],
    "corrected_answer": "...",
    "overall_comment": "..."
  }}
}}
"""
    else:
        # on_topic veya partially_on_topic
        user_prompt = f"""
Soru türü: {question_type or "-"}
Soru metni: \"\"\"{question_text or ""}\"\"\"

Adayın konuşma transkripti:
\"\"\"{transcript}\"\"\"

relevance_level = "{relevance_level}" (on_topic / partially_on_topic)

KURALLAR:

- Eğer relevance_level = "partially_on_topic" ise:
    * overall puanı EN FAZLA 60 ver.
- relevance_level = "on_topic" ise overall puan 0–100 arası serbest.

corrected_answer için:

- corrected_answer HER ZAMAN soruyu DOĞRUDAN cevaplayan,
  4–6 cümlelik İDEAL BİR MÜLAKAT CEVABI olsun.
- Adayın cevabındaki anlamlı kısımları kullanabilirsin ama eksik yerleri tamamla,
  gerekirse yapıyı tamamen yeniden kur.
- Çok kısa selamlama cevapları ("Hello, how are you?" vb.) corrected_answer
  içinde kullanma; direkt soruyu cevaplayan içerik yaz.

Görevin:

1) 0–100 arasında DÖRT skor üret:
   - fluency
   - grammar
   - vocabulary
   - overall

2) 'feedback' alanında şu bilgileri üret:
   - verilen_yanit: Adayın cevabını (transcript) mümkün olduğunca aynen yaz.
   - grammar_errors: Önemli gramer hatalarını TÜRKÇE kısa açıklamalarla liste halinde yaz
     (en fazla 5 madde, hiç hata yoksa ["Belirgin bir gramer hatası yok."] yaz).
   - corrected_answer: Soruyu TAM olarak cevaplayan, 4–6 cümlelik İNGİLİZCE örnek bir mülakat cevabı.
   - overall_comment: Genel TÜRKÇE değerlendirme (2–4 cümle). Eğer relevance_level
     "partially_on_topic" ise, sorunun bazı kısımlarının eksik kaldığını da belirt.

SADECE şu JSON formatında cevap ver:

{{
  "scores": {{
    "fluency": 0,
    "grammar": 0,
    "vocabulary": 0,
    "overall": 0
  }},
  "feedback": {{
    "verilen_yanit": "...",
    "grammar_errors": ["..."],
    "corrected_answer": "...",
    "overall_comment": "..."
  }}
}}
"""

    try:
        chat = get_openai_client().chat.completions.create(
            model="gpt-4o-mini",
            response_format={"type": "json_object"},
            messages=[
                {"role": "system", "content": system_msg},
                {"role": "user", "content": user_prompt},
            ],
        )
        raw_json = chat.choices[0].message.content
        data: Dict = json.loads(raw_json)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"LLM error: {e}")

    scores_raw = data.get("scores", {}) or {}
    feedback = data.get("feedback", {}) or {}

    # -------------------------------------------------------
    # 5) PUANLARI PYTHON TARAFINDA DA ZORLA SINIRLA
    # -------------------------------------------------------
    fluency = _clamp_score(scores_raw.get("fluency", 0))
    grammar = _clamp_score(scores_raw.get("grammar", 0))
    vocab = _clamp_score(scores_raw.get("vocabulary", 0))
    overall = _clamp_score(scores_raw.get("overall", 0))

    if relevance_level == "off_topic":
        fluency = _clamp_score(fluency, 0, 40)
        grammar = _clamp_score(grammar, 0, 40)
        vocab = _clamp_score(vocab, 0, 40)
        overall = _clamp_score(overall, 0, 20)
    elif relevance_level == "partially_on_topic":
        overall = _clamp_score(overall, 0, 60)

    scores = {
        "fluency": fluency,
        "grammar": grammar,
        "vocabulary": vocab,
        "overall": overall,
    }

    meta = {
        "relevance_level": relevance_level,
        "relevance_comment": relevance_comment,
    }

    logger.info("[/evaluate] Değerlendirme tamamlandı.")
    return {
        "question_id": question_id,
        "question_type": question_type,
        "question_text": question_text,
        "transcript": transcript,
        "scores": scores,
        "feedback": feedback,
        "meta": meta,
    }


# ============================================================
# 1b) SINAV SİMÜLASYONU BATCH – Tüm cevaplar tek istekte, paralel OpenAI
# ============================================================
@app.post("/evaluate-batch")
async def evaluate_batch(
    files: List[UploadFile] = File(..., description="Ses dosyaları (sırayla)"),
    metadata: str = Form(..., description="JSON dizi: [{\"question_id\", \"question_type\", \"question_text\"}, ...]"),
):
    """
    Birden fazla cevabı tek istekte alır, sunucuda paralel OpenAI ile değerlendirir.
    İstek OpenAI API'ye gider; her soru hızlıca değerlendirilir.
    """
    if not files:
        raise HTTPException(status_code=400, detail="En az bir dosya gerekli.")
    try:
        meta_list = json.loads(metadata)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"metadata JSON hatası: {e}")
    if not isinstance(meta_list, list) or len(meta_list) != len(files):
        raise HTTPException(
            status_code=400,
            detail=f"metadata, dosya sayısıyla aynı uzunlukta bir dizi olmalı (dosya: {len(files)})."
        )

    async def one_eval(f: UploadFile, m: dict):
        qid = m.get("question_id") or ""
        qtype = m.get("question_type") or ""
        qtext = m.get("question_text") or ""
        try:
            return await _do_evaluate(f, qid, qtype, qtext)
        except Exception as e:
            logger.exception("[/evaluate-batch] Tekil değerlendirme hatası: %s", e)
            raise HTTPException(status_code=500, detail=f"Değerlendirme hatası: {str(e)}")

    logger.info("[/evaluate-batch] %d cevap paralel değerlendiriliyor (OpenAI)...", len(files))
    tasks = [one_eval(f, m) for f, m in zip(files, meta_list)]
    results = await asyncio.gather(*tasks, return_exceptions=True)

    out = []
    for i, r in enumerate(results):
        if isinstance(r, Exception):
            if isinstance(r, HTTPException):
                raise r
            logger.exception("[/evaluate-batch] Öğe %d hata: %s", i, r)
            raise HTTPException(status_code=500, detail=f"Öğe {i}: {str(r)}")
        out.append(r)
    logger.info("[/evaluate-batch] Tüm değerlendirmeler tamamlandı.")
    return {"results": out}


# ============================================================
# 2) GENEL SORULAR /general-evaluate
# ============================================================
@app.post("/general-evaluate")
async def general_evaluate(file: UploadFile = File(...)):
    suffix = os.path.splitext(file.filename)[1] or ".wav"
    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
            tmp.write(await file.read())
            tmp_path = tmp.name
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Temp file error: {e}")

    try:
        transcript = transcribe_tmp_path(tmp_path)
    finally:
        try:
            os.remove(tmp_path)
        except OSError:
            pass

    word_count = len(transcript.split())

    if word_count < 3:
        scores = {"fluency": 0, "grammar": 0, "vocabulary": 0, "overall": 0}
        feedback = {
            "verilen_yanit": transcript or "(Hiç yanıt yok)",
            "grammar_errors": [
                "Cevap yok veya çok kısa olduğu için detaylı değerlendirme yapılamadı."
            ],
            "corrected_answer": "",
            "overall_comment": "Lütfen en az 2–3 cümlelik bir İngilizce yanıt ver.",
        }
        return {
            "transcript": transcript,
            "scores": scores,
            "feedback": feedback,
        }

    system_msg = (
        "Sen THY DLA kabin mülakatı için konuşma değerlendiren çok dikkatli "
        "bir İngilizce öğretmenisin. Sadece JSON üret."
    )

    user_prompt = f"""
Aşağıda adayın konuşmasının transkripti var:

\"\"\"{transcript}\"\"\"

Bu cevap GENEL bir mülakat sorusuna verilmiş kabul edilebilir. Ancak:

- Eğer aday sadece selam veriyor veya kısa, anlamsız/gelişmemiş bir cümle kuruyorsa
  (ör. "Hello, how are you?", "Fine, thanks", "I am good" vb.),
  bu durumda overall puanı EN FAZLA 30,
  fluency/grammar/vocabulary puanlarını EN FAZLA 40 ver.
- Aday birkaç cümleyle kendisini, deneyimini, fikirlerini anlatıyorsa daha yüksek puan verebilirsin.

Görevin:

1) 0–100 arasında DÖRT skor üret:
   - fluency
   - grammar
   - vocabulary
   - overall

2) 'feedback' alanında şu bilgileri üret:
   - verilen_yanit: Adayın verdiği yanıtı (transcript) olduğu gibi yaz.
   - grammar_errors: Önemli gramer hatalarını TÜRKÇE kısa açıklamalarla liste halinde yaz
     (en fazla 5 madde, hiç hata yoksa ["Yok"] yaz).
   - corrected_answer: Aynı cevabın daha düzgün ve gelişmiş bir İNGİLİZCE versiyonunu yaz
     (2–4 cümle).
   - overall_comment: Genel TÜRKÇE değerlendirme (2–4 cümle).

Cevabı SADECE aşağıdaki JSON formatında ver, ek açıklama yazma:

{{
  "scores": {{
    "fluency": 0,
    "grammar": 0,
    "vocabulary": 0,
    "overall": 0
  }},
  "feedback": {{
    "verilen_yanit": "...",
    "grammar_errors": ["..."],
    "corrected_answer": "...",
    "overall_comment": "..."
  }}
}}
"""

    chat = get_openai_client().chat.completions.create(
        model="gpt-4o-mini",
        response_format={"type": "json_object"},
        messages=[
            {"role": "system", "content": system_msg},
            {"role": "user", "content": user_prompt},
        ],
    )

    raw_json = chat.choices[0].message.content
    data: Dict = json.loads(raw_json)

    scores_raw = data.get("scores", {}) or {}
    feedback = data.get("feedback", {}) or {}

    scores = {
        "fluency": _clamp_score(scores_raw.get("fluency", 0)),
        "grammar": _clamp_score(scores_raw.get("grammar", 0)),
        "vocabulary": _clamp_score(scores_raw.get("vocabulary", 0)),
        "overall": _clamp_score(scores_raw.get("overall", 0)),
    }

    return {
        "transcript": transcript,
        "scores": scores,
        "feedback": feedback,
    }


# ============================================================
# 3) SENARYOLAR /scenario-evaluate
# ============================================================
@app.post("/scenario-evaluate")
async def scenario_evaluate(
    file: UploadFile = File(...),
    scenario: str = Form(...),
):
    suffix = os.path.splitext(file.filename)[1] or ".wav"
    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
            tmp.write(await file.read())
            tmp_path = tmp.name
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Temp file error: {e}")

    try:
        transcript = transcribe_tmp_path(tmp_path)
    finally:
        try:
            os.remove(tmp_path)
        except OSError:
            pass

    if is_too_short(transcript, min_words=3):
        feedback = {
            "verilen_yanit": transcript or "(Hiç yanıt yok)",
            "grammar_errors": [
                "Cevap yok veya çok kısa olduğu için detaylı değerlendirme yapılamadı."
            ],
            "corrected_answer": "",
            "overall_comment": "Senaryoya göre en az 2–3 cümlelik bir yanıt vermelisin.",
        }
        return {
            "transcript": transcript,
            "score": 0,
            "feedback": feedback,
        }

    system_msg = (
        "Sen THY DLA mülakatında kabin içi senaryoları değerlendiren bir uzmansın. "
        "Adayın verdiği cevabı hem dil hem de senaryoya uygunluk açısından değerlendir."
    )

    user_prompt = f"""
Senaryo:
\"\"\"{scenario}\"\"\"

Adayın konuşma transkripti:
\"\"\"{transcript}\"\"\"

Görevin:

1) 0–100 arasında tek bir 'score' ver (senaryoya uygunluk, akıcılık, dil kullanımı).
2) 'feedback' içinde:
   - verilen_yanit: Adayın cevabını özetle (İNGİLİZCE veya birebir transcript yaz).
   - grammar_errors: Önemli gramer hatalarını TÜRKÇE kısa açıklamalarla maddeler halinde yaz.
   - corrected_answer: Aynı cevabın daha iyi, doğal ve profesyonel İngilizce ile yazılmış versiyonu (3–6 cümle).
   - overall_comment: Genel TÜRKÇE değerlendirme (2–4 cümle).

SADECE şu JSON formatını dön:

{{
  "score": 0,
  "feedback": {{
    "verilen_yanit": "...",
    "grammar_errors": ["..."],
    "corrected_answer": "...",
    "overall_comment": "..."
  }}
}}
"""

    chat = get_openai_client().chat.completions.create(
        model="gpt-4o-mini",
        response_format={"type": "json_object"},
        messages=[
            {"role": "system", "content": system_msg},
            {"role": "user", "content": user_prompt},
        ],
    )

    raw_json = chat.choices[0].message.content
    data: Dict = json.loads(raw_json)

    score_raw = data.get("score", 0)
    feedback = data.get("feedback", {}) or {}

    score = _clamp_score(score_raw, 0, 100)

    return {
        "transcript": transcript,
        "score": score,
        "feedback": feedback,
    }


# ============================================================
# 4) RESİM AÇIKLAMA /image-evaluate
# ============================================================
@app.post("/image-evaluate")
async def image_evaluate(
    file: UploadFile = File(...),
    prompt: str = Form(...),
):
    suffix = os.path.splitext(file.filename)[1] or ".wav"
    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
            tmp.write(await file.read())
            tmp_path = tmp.name
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Temp file error: {e}")

    try:
        transcript = transcribe_tmp_path(tmp_path)
    finally:
        try:
            os.remove(tmp_path)
        except OSError:
            pass

    if is_too_short(transcript, min_words=3):
        feedback = {
            "image_prompt": prompt,
            "verilen_yanit": transcript or "(Hiç yanıt yok)",
            "grammar_errors": [
                "Cevap yok veya çok kısa olduğu için detaylı değerlendirme yapılamadı."
            ],
            "corrected_answer": "",
            "overall_comment": "Resimde ne gördüğünü en az 2–3 cümleyle anlatmaya çalış.",
        }
        return {
            "transcript": transcript,
            "score": 0,
            "feedback": feedback,
        }

    system_msg = (
        "Sen THY DLA mülakatında resim açıklama bölümünü değerlendiren bir uzmansın. "
        "Adayın resmi ne kadar iyi anlattığını ve dili nasıl kullandığını değerlendir."
    )

    user_prompt = f"""
Resim Görevi Açıklaması:
\"\"\"{prompt}\"\"\"

Adayın konuşma transkripti:
\"\"\"{transcript}\"\"\"

Görevin:

1) 0–100 arasında tek bir 'score' ver (resmi açıklama kalitesi, akıcılık, dil).
2) 'feedback' içinde:
   - image_prompt: Resim görevi metnini (prompt) aynen geri yaz.
   - verilen_yanit: Adayın ne anlattığını özetle (İNGİLİZCE ya da transcript).
   - grammar_errors: Önemli gramer hatalarını TÜRKÇE kısa açıklamalarla maddeler halinde yaz.
   - corrected_answer: Resim için örnek, daha iyi bir açıklama cevabı yaz (3–6 cümle, İngilizce).
   - overall_comment: Genel TÜRKÇE değerlendirme (2–4 cümle).

SADECE şu JSON formatını dön:

{{
  "score": 0,
  "feedback": {{
    "image_prompt": "...",
    "verilen_yanit": "...",
    "grammar_errors": ["..."],
    "corrected_answer": "...",
    "overall_comment": "..."
  }}
}}
"""

    chat = get_openai_client().chat.completions.create(
        model="gpt-4o-mini",
        response_format={"type": "json_object"},
        messages=[
            {"role": "system", "content": system_msg},
            {"role": "user", "content": user_prompt},
        ],
    )

    raw_json = chat.choices[0].message.content
    data: Dict = json.loads(raw_json)

    score_raw = data.get("score", 0)
    feedback = data.get("feedback", {}) or {}

    score = _clamp_score(score_raw, 0, 100)

    return {
        "transcript": transcript,
        "score": score,
        "feedback": feedback,
    }


# ============================================================
# 5) SÖZLÜK /dictionary
# ============================================================
class DictionaryRequest(BaseModel):
    word: str


@app.post("/dictionary")
async def dictionary_lookup(req: DictionaryRequest):
    word = req.word.strip()
    if not word:
        raise HTTPException(status_code=400, detail="Word is required")

    system_msg = (
        "Sen THY DLA sınavına hazırlanan adaylar için HAVACILIK ve GÜNDELİK "
        "İNGİLİZCE sözlüğü hazırlayan bir uzmansın. "
        "Hem basit açıklama hem de sınav açısından önemli noktaları vurgula."
    )

    user_prompt = f"""
Kelime/ifade: "{word}"

Bu kelime için aşağıdaki bilgileri üret:

1) definition_en: Basit, net ve kısa İNGİLİZCE açıklama (B1-B2 seviyesinde).
2) definition_tr: Kısa ve net TÜRKÇE açıklama.
3) example_sentence: Kelimeyi içeren, kabin görevlisi / yolcu bağlamında bir İngilizce örnek cümle.
4) synonyms: İngilizce 2–5 tane yakın anlamlı kelime veya kısa ifade (liste).
5) dla_tip: TÜRKÇE olarak, DLA mülakatında bu kelimeyi nasıl kullanabileceğine dair kısa bir ipucu.

SADECE şu JSON formatında cevap ver:

{{
  "word": "{word}",
  "definition_en": "...",
  "definition_tr": "...",
  "example_sentence": "...",
  "synonyms": ["...", "..."],
  "dla_tip": "..."
}}
"""

    chat = get_openai_client().chat.completions.create(
        model="gpt-4o-mini",
        response_format={"type": "json_object"},
        messages=[
            {"role": "system", "content": system_msg},
            {"role": "user", "content": user_prompt},
        ],
    )

    raw_json = chat.choices[0].message.content
    data: Dict = json.loads(raw_json)

    return data


# ============================================================
# 6) SORU GÖNDER /submit-question
# ============================================================
class UserQuestionPayload(BaseModel):
    category: str
    question: str
    email: Optional[str] = None


@app.post("/submit-question")
async def submit_question(payload: UserQuestionPayload):
    from app.database import async_session_maker
    from app.models import UserQuestion as UserQuestionModel

    if async_session_maker:
        async with async_session_maker() as session:
            row = UserQuestionModel(
                category=payload.category,
                question=payload.question,
                email=payload.email,
                source="mobile-app",
            )
            session.add(row)
            await session.commit()
    else:
        save_path = os.path.join(os.path.dirname(__file__), "user_questions.jsonl")
        record = {
            "category": payload.category,
            "question": payload.question,
            "email": payload.email,
            "source": "mobile-app",
        }
        with open(save_path, "a", encoding="utf-8") as f:
            f.write(json.dumps(record, ensure_ascii=False) + "\n")

    return {"ok": True}


# ============================================================
# 7) ÇEVİRİ /translate  (EN -> TR vb.)
# ============================================================
class TranslateRequest(BaseModel):
    text: str
    target_lang: str = "tr"   # varsayılan Türkçe


@app.post("/translate")
async def translate(req: TranslateRequest):
    text = (req.text or "").strip()
    if not text:
        raise HTTPException(status_code=400, detail="Text is required")

    target_lang = (req.target_lang or "tr").strip()

    system_msg = (
        "You are a professional translator. "
        "You receive a piece of text and a target language, and you respond "
        "ONLY with the translation, without any explanations, notes or quotes."
    )

    user_prompt = f"Target language: {target_lang}\n\nText:\n{text}"

    try:
        chat = get_openai_client().chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": system_msg},
                {"role": "user", "content": user_prompt},
            ],
        )
        translated = chat.choices[0].message.content.strip()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Translation error: {e}")

    return {"translated_text": translated}
