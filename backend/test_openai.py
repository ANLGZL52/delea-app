"""OpenAI API bağlantı testi - backend .env kullanır"""
import os
from dotenv import load_dotenv
load_dotenv()

key = os.getenv("OPENAI_API_KEY")
print(f"API Key yüklendi: {bool(key)}")
print(f"Key başlangıç: {key[:15]}..." if key else "KEY YOK")

if not key:
    print("HATA: OPENAI_API_KEY .env dosyasında bulunamadı.")
    exit(1)

from openai import OpenAI
client = OpenAI(api_key=key.strip(), timeout=60)

print("\n1. OpenAI Chat testi...")
try:
    r = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{"role": "user", "content": "Say only: OK"}],
        max_tokens=10,
    )
    print(f"   Yanıt: {r.choices[0].message.content}")
    print("   Chat API: ÇALIŞIYOR")
except Exception as e:
    print(f"   HATA: {e}")
    exit(1)

print("\n2. OpenAI Transcription testi (kısa ses)...")
# 1 saniyelik boş/sessiz WAV (44.1kHz mono) - minimal test
import tempfile
import struct
with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as f:
    # Minimal WAV header + 0.1 sn silence
    rate, channels = 44100, 1
    samples = int(rate * 0.1) * channels
    f.write(b"RIFF")
    f.write(struct.pack("<I", 36 + samples * 2))
    f.write(b"WAVEfmt ")
    f.write(struct.pack("<IHHIIHH", 16, 1, channels, rate, rate * channels * 2, channels * 2, 16))
    f.write(b"data")
    f.write(struct.pack("<I", samples * 2))
    f.write(b"\x00" * (samples * 2))
    tmp = f.name

try:
    with open(tmp, "rb") as af:
        t = client.audio.transcriptions.create(
            model="gpt-4o-mini-transcribe",
            file=af,
            response_format="json",
            language="en",
        )
    print(f"   Transcription: {repr(t.text)[:80]}")
    print("   Transcription API: ÇALIŞIYOR")
except Exception as e:
    print(f"   HATA: {e}")
finally:
    os.unlink(tmp)

print("\n--- Tüm testler geçti. OpenAI bağlantısı çalışıyor. ---")
