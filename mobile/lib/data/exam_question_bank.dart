import '../models/exam_question.dart';
// lib/data/exam_question_bank.dart

import 'dart:math';

class ExamQuestionBank {
 // 2 sabit giriş sorusu (15 sn)
static final List<ExamQuestion> introQuestions = [
  ExamQuestion(
    id: 'intro_1',
    type: 'intro',
    text: 'What is your full name?',
  ),
  ExamQuestion(
    id: 'intro_2',
    type: 'intro',
    text: 'What is your ID number?',
  ),
];


  // ==========================
  // GENEL SORULAR (60 ADET)
  // ==========================
  static List<ExamQuestion> generalQuestions = [
    ExamQuestion(
      id: 'gen_1',
      type: 'general',
      text: 'Can you tell me about your previous work or study experience?',
    ),
    ExamQuestion(
      id: 'gen_2',
      type: 'general',
      text: 'Why do you want to become a cabin crew member?',
    ),
    ExamQuestion(
      id: 'gen_3',
      type: 'general',
      text: 'How do you deal with stress in a busy environment?',
    ),
    ExamQuestion(
      id: 'gen_4',
      type: 'general',
      text: 'What do you think is the most challenging part of this job?',
    ),
    ExamQuestion(
      id: 'gen_5',
      type: 'general',
      text:
          'Describe a time when you worked in a team and things went well. What made it successful?',
    ),
    ExamQuestion(
      id: 'gen_6',
      type: 'general',
      text:
          'Describe a situation where you had a conflict with someone. How did you handle it?',
    ),
    ExamQuestion(
      id: 'gen_7',
      type: 'general',
      text: 'How would your friends describe your personality?',
    ),
    ExamQuestion(
      id: 'gen_8',
      type: 'general',
      text: 'What does excellent customer service mean to you?',
    ),
    ExamQuestion(
      id: 'gen_9',
      type: 'general',
      text:
          'Tell me about a time you solved a problem for a customer or another person.',
    ),
    ExamQuestion(
      id: 'gen_10',
      type: 'general',
      text: 'Why is safety important on board an aircraft?',
    ),
    ExamQuestion(
      id: 'gen_11',
      type: 'general',
      text:
          'What do you usually do in your free time to relax and recharge yourself?',
    ),
    ExamQuestion(
      id: 'gen_12',
      type: 'general',
      text:
          'Have you ever worked in a multicultural environment? How was your experience?',
    ),
    ExamQuestion(
      id: 'gen_13',
      type: 'general',
      text:
          'What personal qualities do you have that make you suitable for cabin crew?',
    ),
    ExamQuestion(
      id: 'gen_14',
      type: 'general',
      text:
          'Tell me about a time when you had to learn something new quickly. How did you manage?',
    ),
    ExamQuestion(
      id: 'gen_15',
      type: 'general',
      text:
          'If you join an airline company, what would be your long-term career goals?',
    ),
    ExamQuestion(
      id: 'gen_16',
      type: 'general',
      text:
          'How do you stay calm when many people are asking for help at the same time?',
    ),
    ExamQuestion(
      id: 'gen_17',
      type: 'general',
      text:
          'What do you think passengers expect from a professional cabin crew member?',
    ),
    ExamQuestion(
      id: 'gen_18',
      type: 'general',
      text:
          'Describe a time you received negative feedback. What did you learn from it?',
    ),
    ExamQuestion(
      id: 'gen_19',
      type: 'general',
      text:
          'How do you organise your day when you have many tasks to complete?',
    ),
    ExamQuestion(
      id: 'gen_20',
      type: 'general',
      text:
          'What does “team spirit” mean to you and how do you contribute to it?',
    ),
    ExamQuestion(
      id: 'gen_21',
      type: 'general',
      text:
          'Tell me about a situation where you had to adapt to a sudden change.',
    ),
    ExamQuestion(
      id: 'gen_22',
      type: 'general',
      text:
          'Why is cultural awareness important for a cabin crew member working on international flights?',
    ),
    ExamQuestion(
      id: 'gen_23',
      type: 'general',
      text:
          'Describe a time you went the extra mile to help someone. What did you do?',
    ),
    ExamQuestion(
      id: 'gen_24',
      type: 'general',
      text:
          'How do you feel about working irregular hours, weekends and holidays?',
    ),
    ExamQuestion(
      id: 'gen_25',
      type: 'general',
      text:
          'What strategies do you use to improve your English or other foreign languages?',
    ),
    ExamQuestion(
      id: 'gen_26',
      type: 'general',
      text:
          'What is more important for you: following procedures or keeping the customer happy? Why?',
    ),
    ExamQuestion(
      id: 'gen_27',
      type: 'general',
      text:
          'Describe a stressful day you recently had. How did you manage your emotions?',
    ),
    ExamQuestion(
      id: 'gen_28',
      type: 'general',
      text:
          'How would you handle a situation where a colleague is not doing their job properly?',
    ),
    ExamQuestion(
      id: 'gen_29',
      type: 'general',
      text:
          'What motivates you the most in your personal or professional life?',
    ),
    ExamQuestion(
      id: 'gen_30',
      type: 'general',
      text:
          'If a passenger is not polite to you, how would you react while staying professional?',
    ),
    ExamQuestion(
      id: 'gen_31',
      type: 'general',
      text:
          'Tell me about a time you had to explain something complex in a simple way.',
    ),
    ExamQuestion(
      id: 'gen_32',
      type: 'general',
      text:
          'How do you prepare yourself mentally and physically before an important exam or interview?',
    ),
    ExamQuestion(
      id: 'gen_33',
      type: 'general',
      text:
          'What safety-related responsibilities do you think cabin crew have during a flight?',
    ),
    ExamQuestion(
      id: 'gen_34',
      type: 'general',
      text:
          'Describe a time you had to make a quick decision. What was the result?',
    ),
    ExamQuestion(
      id: 'gen_35',
      type: 'general',
      text:
          'How would you deal with a situation where you do not know the answer to a passenger’s question?',
    ),
    ExamQuestion(
      id: 'gen_36',
      type: 'general',
      text:
          'What kind of passengers do you find most difficult to deal with and why?',
    ),
    ExamQuestion(
      id: 'gen_37',
      type: 'general',
      text:
          'How do you manage your emotions when you feel tired but still need to provide good service?',
    ),
    ExamQuestion(
      id: 'gen_38',
      type: 'general',
      text:
          'What do you think are the main differences between good service and excellent service?',
    ),
    ExamQuestion(
      id: 'gen_39',
      type: 'general',
      text:
          'Tell me about a time when you had to work with someone very different from you.',
    ),
    ExamQuestion(
      id: 'gen_40',
      type: 'general',
      text:
          'What do you do to keep yourself positive and motivated during difficult periods in your life?',
    ),
    ExamQuestion(
      id: 'gen_41',
      type: 'general',
      text:
          'If you see a colleague being rude to a passenger, what would you do?',
    ),
    ExamQuestion(
      id: 'gen_42',
      type: 'general',
      text:
          'How important is personal appearance and grooming for a cabin crew member?',
    ),
    ExamQuestion(
      id: 'gen_43',
      type: 'general',
      text:
          'Describe a time when you had to follow strict rules. How did you feel about it?',
    ),
    ExamQuestion(
      id: 'gen_44',
      type: 'general',
      text:
          'What do you think are the advantages and disadvantages of working as cabin crew?',
    ),
    ExamQuestion(
      id: 'gen_45',
      type: 'general',
      text:
          'How do you deal with passengers who do not speak the same language as you?',
    ),
    ExamQuestion(
      id: 'gen_46',
      type: 'general',
      text:
          'Tell me about a situation where you made a mistake. How did you correct it?',
    ),
    ExamQuestion(
      id: 'gen_47',
      type: 'general',
      text:
          'What does “professionalism” mean to you in the context of cabin crew?',
    ),
    ExamQuestion(
      id: 'gen_48',
      type: 'general',
      text:
          'How would you handle a long flight where you feel physically and mentally exhausted?',
    ),
    ExamQuestion(
      id: 'gen_49',
      type: 'general',
      text:
          'What kind of training or learning are you willing to do to become a better cabin crew member?',
    ),
    ExamQuestion(
      id: 'gen_50',
      type: 'general',
      text:
          'Why do you think teamwork is especially important on board an aircraft?',
    ),
    ExamQuestion(
      id: 'gen_51',
      type: 'general',
      text:
          'Describe a time you had to stay calm when other people were nervous or upset.',
    ),
    ExamQuestion(
      id: 'gen_52',
      type: 'general',
      text:
          'If a passenger asks you for something that is against company rules, how would you respond?',
    ),
    ExamQuestion(
      id: 'gen_53',
      type: 'general',
      text:
          'What hobbies or interests do you have that might help you in this job?',
    ),
    ExamQuestion(
      id: 'gen_54',
      type: 'general',
      text:
          'Do you prefer working alone or in a team? Why? Give an example.',
    ),
    ExamQuestion(
      id: 'gen_55',
      type: 'general',
      text:
          'How would you react if a passenger complained about you personally?',
    ),
    ExamQuestion(
      id: 'gen_56',
      type: 'general',
      text:
          'What do you think is the most important communication skill for cabin crew?',
    ),
    ExamQuestion(
      id: 'gen_57',
      type: 'general',
      text:
          'Tell me about a time you stayed calm under pressure and still did a good job.',
    ),
    ExamQuestion(
      id: 'gen_58',
      type: 'general',
      text:
          'How do you balance being friendly with passengers and still keeping authority and safety in mind?',
    ),
    ExamQuestion(
      id: 'gen_59',
      type: 'general',
      text:
          'What does “going above and beyond” for a passenger look like to you?',
    ),
    ExamQuestion(
      id: 'gen_60',
      type: 'general',
      text:
          'If you could describe your ideal working day as a cabin crew member, what would it look like?',
    ),
        // EK GENEL SORULAR (61–100)
    ExamQuestion(
      id: 'gen_61',
      type: 'general',
      text:
          'Tell me about a time when you had to handle more than one responsibility at the same time.',
    ),
    ExamQuestion(
      id: 'gen_62',
      type: 'general',
      text:
          'What kind of passengers do you enjoy serving the most and why?',
    ),
    ExamQuestion(
      id: 'gen_63',
      type: 'general',
      text:
          'Describe a situation where you had to stay polite even if you did not agree with the other person.',
    ),
    ExamQuestion(
      id: 'gen_64',
      type: 'general',
      text:
          'How do you usually react when plans change at the last minute?',
    ),
    ExamQuestion(
      id: 'gen_65',
      type: 'general',
      text:
          'What does “safety first” mean to you in your daily life, not only on an aircraft?',
    ),
    ExamQuestion(
      id: 'gen_66',
      type: 'general',
      text:
          'Tell me about a time you supported a friend, classmate or colleague who was having a hard time.',
    ),
    ExamQuestion(
      id: 'gen_67',
      type: 'general',
      text:
          'How do you feel about giving and receiving feedback from others?',
    ),
    ExamQuestion(
      id: 'gen_68',
      type: 'general',
      text:
          'Describe a time when you had to follow instructions very carefully. What happened?',
    ),
    ExamQuestion(
      id: 'gen_69',
      type: 'general',
      text:
          'What do you think is the best way to deal with a misunderstanding between you and a passenger?',
    ),
    ExamQuestion(
      id: 'gen_70',
      type: 'general',
      text:
          'If you made a mistake during a flight, how would you react and what would you do next?',
    ),
    ExamQuestion(
      id: 'gen_71',
      type: 'general',
      text:
          'How important is punctuality for you? Give an example from your life.',
    ),
    ExamQuestion(
      id: 'gen_72',
      type: 'general',
      text:
          'Describe a situation where you had to stay patient for a long time.',
    ),
    ExamQuestion(
      id: 'gen_73',
      type: 'general',
      text:
          'How would you describe your communication style when you meet new people?',
    ),
    ExamQuestion(
      id: 'gen_74',
      type: 'general',
      text:
          'Why do you think working with people from different cultures is interesting or challenging?',
    ),
    ExamQuestion(
      id: 'gen_75',
      type: 'general',
      text:
          'Tell me about a time when you had to calm down someone who was angry or upset.',
    ),
    ExamQuestion(
      id: 'gen_76',
      type: 'general',
      text:
          'What do you think is the most important daily habit for maintaining a professional image?',
    ),
    ExamQuestion(
      id: 'gen_77',
      type: 'general',
      text:
          'If your supervisor gave you an order that you did not fully understand, what would you do?',
    ),
    ExamQuestion(
      id: 'gen_78',
      type: 'general',
      text:
          'Describe a time when you needed to apologise. How did you do it?',
    ),
    ExamQuestion(
      id: 'gen_79',
      type: 'general',
      text:
          'What kind of situations make you feel stressed, and how do you control this stress?',
    ),
    ExamQuestion(
      id: 'gen_80',
      type: 'general',
      text:
          'How do you keep yourself organised when you travel or prepare for a trip?',
    ),
    ExamQuestion(
      id: 'gen_81',
      type: 'general',
      text:
          'Tell me about a time when you had to motivate other people to continue working.',
    ),
    ExamQuestion(
      id: 'gen_82',
      type: 'general',
      text:
          'How would you respond if a passenger asked you personal questions you do not want to answer?',
    ),
    ExamQuestion(
      id: 'gen_83',
      type: 'general',
      text:
          'What is one weakness you are actively trying to improve? How are you working on it?',
    ),
    ExamQuestion(
      id: 'gen_84',
      type: 'general',
      text:
          'Describe a project, task or activity that you are proud of. Why is it important to you?',
    ),
    ExamQuestion(
      id: 'gen_85',
      type: 'general',
      text:
          'How do you react when someone gives you unfair criticism?',
    ),
    ExamQuestion(
      id: 'gen_86',
      type: 'general',
      text:
          'What kind of leader do you prefer to work with and why?',
    ),
    ExamQuestion(
      id: 'gen_87',
      type: 'general',
      text:
          'Tell me about a time when you had to follow a decision you did not agree with.',
    ),
    ExamQuestion(
      id: 'gen_88',
      type: 'general',
      text:
          'How would you explain the importance of safety demonstrations to a passenger who is not paying attention?',
    ),
    ExamQuestion(
      id: 'gen_89',
      type: 'general',
      text:
          'What role does empathy play in customer service, in your opinion?',
    ),
    ExamQuestion(
      id: 'gen_90',
      type: 'general',
      text:
          'Describe a time when you had to be very detail-oriented. What could have gone wrong if you were not careful?',
    ),
    ExamQuestion(
      id: 'gen_91',
      type: 'general',
      text:
          'How do you feel about handling money or valuable items for passengers?',
    ),
    ExamQuestion(
      id: 'gen_92',
      type: 'general',
      text:
          'What do you think is the best way to handle gossip or negative talk among colleagues?',
    ),
    ExamQuestion(
      id: 'gen_93',
      type: 'general',
      text:
          'Tell me about a time when you had to say “no” to someone. How did you do it politely?',
    ),
    ExamQuestion(
      id: 'gen_94',
      type: 'general',
      text:
          'What do you do when you feel you are losing concentration during a long task?',
    ),
    ExamQuestion(
      id: 'gen_95',
      type: 'general',
      text:
          'How would you handle a situation where two passengers ask for your help at exactly the same time?',
    ),
    ExamQuestion(
      id: 'gen_96',
      type: 'general',
      text:
          'Describe a time when you had to respect a rule you personally did not like.',
    ),
    ExamQuestion(
      id: 'gen_97',
      type: 'general',
      text:
          'What does “confidentiality” mean to you, and why is it important in aviation?',
    ),
    ExamQuestion(
      id: 'gen_98',
      type: 'general',
      text:
          'If you realised that you misunderstood a passenger’s request, what would you do?',
    ),
    ExamQuestion(
      id: 'gen_99',
      type: 'general',
      text:
          'How do you feel about working under strict time pressure? Give an example.',
    ),
    ExamQuestion(
      id: 'gen_100',
      type: 'general',
      text:
          'Imagine you have just finished a difficult flight. How would you reflect on your performance and improve next time?',
    ),
        // EK GENEL SORULAR (101–160)
    ExamQuestion(
      id: 'gen_101',
      type: 'general',
      text:
          'How do you usually react when a plan does not go as expected? Give an example.',
    ),
    ExamQuestion(
      id: 'gen_102',
      type: 'general',
      text:
          'Describe a time when you had to work with limited resources. How did you manage?',
    ),
    ExamQuestion(
      id: 'gen_103',
      type: 'general',
      text:
          'What do you think is the most important quality of a cabin crew member and why?',
    ),
    ExamQuestion(
      id: 'gen_104',
      type: 'general',
      text:
          'Tell me about a situation where you had to control your emotions in front of others.',
    ),
    ExamQuestion(
      id: 'gen_105',
      type: 'general',
      text:
          'How do you make sure you understand instructions correctly before you act?',
    ),
    ExamQuestion(
      id: 'gen_106',
      type: 'general',
      text:
          'Describe a time when you helped someone who did not ask for help directly.',
    ),
    ExamQuestion(
      id: 'gen_107',
      type: 'general',
      text:
          'What does “responsibility” mean to you in a job like cabin crew?',
    ),
    ExamQuestion(
      id: 'gen_108',
      type: 'general',
      text:
          'How do you react when you see a colleague who looks tired or stressed at work?',
    ),
    ExamQuestion(
      id: 'gen_109',
      type: 'general',
      text:
          'Tell me about a time when you had to be very careful with confidential or sensitive information.',
    ),
    ExamQuestion(
      id: 'gen_110',
      type: 'general',
      text:
          'How do you prepare yourself mentally for an important responsibility?',
    ),
    ExamQuestion(
      id: 'gen_111',
      type: 'general',
      text:
          'Describe a situation where you had to choose between what is easy and what is right.',
    ),
    ExamQuestion(
      id: 'gen_112',
      type: 'general',
      text:
          'What kind of behaviour from colleagues motivates you the most during a busy day?',
    ),
    ExamQuestion(
      id: 'gen_113',
      type: 'general',
      text:
          'How do you stay polite when someone is speaking to you in an unfriendly tone?',
    ),
    ExamQuestion(
      id: 'gen_114',
      type: 'general',
      text:
          'Tell me about a time you had to change your communication style for a different person.',
    ),
    ExamQuestion(
      id: 'gen_115',
      type: 'general',
      text:
          'What do you think is the best way to build trust with passengers?',
    ),
    ExamQuestion(
      id: 'gen_116',
      type: 'general',
      text:
          'Describe a time when you had to learn a new rule or system quickly and use it correctly.',
    ),
    ExamQuestion(
      id: 'gen_117',
      type: 'general',
      text:
          'How do you keep a positive attitude when you feel physically tired?',
    ),
    ExamQuestion(
      id: 'gen_118',
      type: 'general',
      text:
          'What kind of situations require you to be especially careful with your words?',
    ),
    ExamQuestion(
      id: 'gen_119',
      type: 'general',
      text:
          'Tell me about a time when you had to give bad news to someone in a kind way.',
    ),
    ExamQuestion(
      id: 'gen_120',
      type: 'general',
      text:
          'How do you usually solve misunderstandings between you and another person?',
    ),
    ExamQuestion(
      id: 'gen_121',
      type: 'general',
      text:
          'Describe a time when you helped to create a positive atmosphere in a group.',
    ),
    ExamQuestion(
      id: 'gen_122',
      type: 'general',
      text:
          'What do you do when you feel that you are losing patience with someone?',
    ),
    ExamQuestion(
      id: 'gen_123',
      type: 'general',
      text:
          'How important is listening compared to speaking in good communication, in your opinion?',
    ),
    ExamQuestion(
      id: 'gen_124',
      type: 'general',
      text:
          'Tell me about a time when you had to adjust your body language to appear more professional.',
    ),
    ExamQuestion(
      id: 'gen_125',
      type: 'general',
      text:
          'How would you describe your way of handling criticism from a supervisor?',
    ),
    ExamQuestion(
      id: 'gen_126',
      type: 'general',
      text:
          'Describe a situation where you supported a team member who was struggling with a task.',
    ),
    ExamQuestion(
      id: 'gen_127',
      type: 'general',
      text:
          'What do you do to stay informed and up to date about rules or procedures in a job?',
    ),
    ExamQuestion(
      id: 'gen_128',
      type: 'general',
      text:
          'How do you react when you see unfair behaviour towards a colleague or passenger?',
    ),
    ExamQuestion(
      id: 'gen_129',
      type: 'general',
      text:
          'Tell me about a time when you had to stay calm while other people were watching you.',
    ),
    ExamQuestion(
      id: 'gen_130',
      type: 'general',
      text:
          'What is your strategy to keep a friendly tone even when you are giving firm instructions?',
    ),
    ExamQuestion(
      id: 'gen_131',
      type: 'general',
      text:
          'Describe a time when you took initiative without being asked. What happened?',
    ),
    ExamQuestion(
      id: 'gen_132',
      type: 'general',
      text:
          'How do you feel about working in a highly structured and rule-based environment?',
    ),
    ExamQuestion(
      id: 'gen_133',
      type: 'general',
      text:
          'Tell me about a situation where your attention to detail prevented a problem.',
    ),
    ExamQuestion(
      id: 'gen_134',
      type: 'general',
      text:
          'What kind of passengers might find it difficult to follow safety instructions, and how would you handle them?',
    ),
    ExamQuestion(
      id: 'gen_135',
      type: 'general',
      text:
          'How do you respond when you feel that someone is not respecting your personal boundaries?',
    ),
    ExamQuestion(
      id: 'gen_136',
      type: 'general',
      text:
          'Describe a time when you had to remember many details at the same time. How did you manage?',
    ),
    ExamQuestion(
      id: 'gen_137',
      type: 'general',
      text:
          'What role does body language play in your communication with others?',
    ),
    ExamQuestion(
      id: 'gen_138',
      type: 'general',
      text:
          'How do you handle a situation where someone speaks very fast or unclearly in English?',
    ),
    ExamQuestion(
      id: 'gen_139',
      type: 'general',
      text:
          'Tell me about a time when you had to stay professional even if you felt emotional inside.',
    ),
    ExamQuestion(
      id: 'gen_140',
      type: 'general',
      text:
          'What habits help you to be reliable and consistent in your daily responsibilities?',
    ),
    ExamQuestion(
      id: 'gen_141',
      type: 'general',
      text:
          'Describe a time when you had to comfort someone who was anxious about travelling.',
    ),
    ExamQuestion(
      id: 'gen_142',
      type: 'general',
      text:
          'How do you react when things are not organised the way you expected?',
    ),
    ExamQuestion(
      id: 'gen_143',
      type: 'general',
      text:
          'What do you think is the most difficult part of communicating with passengers during an emergency?',
    ),
    ExamQuestion(
      id: 'gen_144',
      type: 'general',
      text:
          'Tell me about a time when you successfully calmed down a stressful situation.',
    ),
    ExamQuestion(
      id: 'gen_145',
      type: 'general',
      text:
          'How do you balance being friendly and keeping a professional distance from passengers?',
    ),
    ExamQuestion(
      id: 'gen_146',
      type: 'general',
      text:
          'Describe a time when you had to solve a problem without much guidance from others.',
    ),
    ExamQuestion(
      id: 'gen_147',
      type: 'general',
      text:
          'What personal values guide you most when you make decisions at work?',
    ),
    ExamQuestion(
      id: 'gen_148',
      type: 'general',
      text:
          'How do you manage your time when you have many small tasks to complete in a short period?',
    ),
    ExamQuestion(
      id: 'gen_149',
      type: 'general',
      text:
          'Tell me about a time when you noticed a small detail that turned out to be very important.',
    ),
    ExamQuestion(
      id: 'gen_150',
      type: 'general',
      text:
          'What kind of passenger behaviour makes you feel most challenged, and how would you handle it?',
    ),
    ExamQuestion(
      id: 'gen_151',
      type: 'general',
      text:
          'How would you describe your ability to stay neutral in conflicts between other people?',
    ),
    ExamQuestion(
      id: 'gen_152',
      type: 'general',
      text:
          'Describe a time when you had to repeat the same information many times. How did you stay patient?',
    ),
    ExamQuestion(
      id: 'gen_153',
      type: 'general',
      text:
          'What is your strategy for staying focused in a noisy or crowded environment?',
    ),
    ExamQuestion(
      id: 'gen_154',
      type: 'general',
      text:
          'How do you adapt your communication when speaking to someone older than you compared to someone younger?',
    ),
    ExamQuestion(
      id: 'gen_155',
      type: 'general',
      text:
          'Tell me about a time when you had to change your opinion after receiving new information.',
    ),
    ExamQuestion(
      id: 'gen_156',
      type: 'general',
      text:
          'What do you do to maintain your mental health and well-being during stressful periods?',
    ),
    ExamQuestion(
      id: 'gen_157',
      type: 'general',
      text:
          'Describe a time when you supported a decision that was not popular but necessary.',
    ),
    ExamQuestion(
      id: 'gen_158',
      type: 'general',
      text:
          'How would you describe your style of dealing with shy or quiet passengers?',
    ),
    ExamQuestion(
      id: 'gen_159',
      type: 'general',
      text:
          'What do you think is the most important thing passengers remember about a flight?',
    ),
    ExamQuestion(
      id: 'gen_160',
      type: 'general',
      text:
          'If you look at your personality, what makes you especially suitable for working in the cabin environment?',
    ),
        // EK GENEL SORULAR (161–220)
    ExamQuestion(
      id: 'gen_161',
      type: 'general',
      text:
          'Tell me about a situation where you needed to stay professional even when you strongly disagreed with someone.',
    ),
    ExamQuestion(
      id: 'gen_162',
      type: 'general',
      text:
          'What strategies do you use to remember important information during busy tasks?',
    ),
    ExamQuestion(
      id: 'gen_163',
      type: 'general',
      text:
          'Describe a moment when you made someone feel comfortable in a stressful situation.',
    ),
    ExamQuestion(
      id: 'gen_164',
      type: 'general',
      text:
          'How do you usually handle situations where people interrupt you while speaking?',
    ),
    ExamQuestion(
      id: 'gen_165',
      type: 'general',
      text:
          'What does “being adaptable” mean to you, and can you give an example?',
    ),
    ExamQuestion(
      id: 'gen_166',
      type: 'general',
      text:
          'Tell me about a time when you had to follow a rule that others around you ignored.',
    ),
    ExamQuestion(
      id: 'gen_167',
      type: 'general',
      text:
          'What is the most important thing you have learned about communication in the last year?',
    ),
    ExamQuestion(
      id: 'gen_168',
      type: 'general',
      text:
          'How do you react when someone raises their voice at you?',
    ),
    ExamQuestion(
      id: 'gen_169',
      type: 'general',
      text:
          'Describe a time when you had to calm down someone who misunderstood your intentions.',
    ),
    ExamQuestion(
      id: 'gen_170',
      type: 'general',
      text:
          'What daily habits help you stay organised and responsible?',
    ),
    ExamQuestion(
      id: 'gen_171',
      type: 'general',
      text:
          'Tell me about a time you worked with someone who had a very different personality from yours.',
    ),
    ExamQuestion(
      id: 'gen_172',
      type: 'general',
      text:
          'How do you motivate yourself when you feel overwhelmed?',
    ),
    ExamQuestion(
      id: 'gen_173',
      type: 'general',
      text:
          'Describe a moment you realised clear communication prevented a serious problem.',
    ),
    ExamQuestion(
      id: 'gen_174',
      type: 'general',
      text:
          'How do you handle situations where you must repeat instructions many times?',
    ),
    ExamQuestion(
      id: 'gen_175',
      type: 'general',
      text:
          'Tell me about a time when you had to take responsibility for something unexpected.',
    ),
    ExamQuestion(
      id: 'gen_176',
      type: 'general',
      text:
          'What steps do you take to remain patient with difficult people?',
    ),
    ExamQuestion(
      id: 'gen_177',
      type: 'general',
      text:
          'Describe a time when you had to deliver information very clearly to avoid confusion.',
    ),
    ExamQuestion(
      id: 'gen_178',
      type: 'general',
      text:
          'How do you maintain a polite tone even when you feel stressed?',
    ),
    ExamQuestion(
      id: 'gen_179',
      type: 'general',
      text:
          'What do you think is the role of empathy in teamwork?',
    ),
    ExamQuestion(
      id: 'gen_180',
      type: 'general',
      text:
          'Tell me about a time when you adjusted your behaviour to support someone’s emotional state.',
    ),
    ExamQuestion(
      id: 'gen_181',
      type: 'general',
      text:
          'How do you respond when you feel ignored during group discussions?',
    ),
    ExamQuestion(
      id: 'gen_182',
      type: 'general',
      text:
          'Describe a time you made a positive impact on someone’s experience without being asked.',
    ),
    ExamQuestion(
      id: 'gen_183',
      type: 'general',
      text:
          'What do you think is the hardest part of managing customer emotions?',
    ),
    ExamQuestion(
      id: 'gen_184',
      type: 'general',
      text:
          'How do you balance speed and accuracy when working under pressure?',
    ),
    ExamQuestion(
      id: 'gen_185',
      type: 'general',
      text:
          'Tell me about a moment where your careful observation helped avoid a problem.',
    ),
    ExamQuestion(
      id: 'gen_186',
      type: 'general',
      text:
          'How do you handle situations where multiple people need your help simultaneously?',
    ),
    ExamQuestion(
      id: 'gen_187',
      type: 'general',
      text:
          'What do you think is the key to building trust quickly with someone?',
    ),
    ExamQuestion(
      id: 'gen_188',
      type: 'general',
      text:
          'Describe a time you stayed respectful even when someone was being unreasonable.',
    ),
    ExamQuestion(
      id: 'gen_189',
      type: 'general',
      text:
          'How do you ensure you remain objective when handling conflicts?',
    ),
    ExamQuestion(
      id: 'gen_190',
      type: 'general',
      text:
          'Tell me about a time when you supported someone without taking sides.',
    ),
    ExamQuestion(
      id: 'gen_191',
      type: 'general',
      text:
          'What do you learn about yourself when you face stressful situations?',
    ),
    ExamQuestion(
      id: 'gen_192',
      type: 'general',
      text:
          'How do you react when someone challenges your instructions or authority?',
    ),
    ExamQuestion(
      id: 'gen_193',
      type: 'general',
      text:
          'Describe a time when you needed to stay alert for long hours. How did you manage?',
    ),
    ExamQuestion(
      id: 'gen_194',
      type: 'general',
      text:
          'What steps do you take to stay open-minded when listening to others?',
    ),
    ExamQuestion(
      id: 'gen_195',
      type: 'general',
      text:
          'Tell me about a moment you learned something important from a small mistake.',
    ),
    ExamQuestion(
      id: 'gen_196',
      type: 'general',
      text:
          'How do you show respect in conversations, even with strangers?',
    ),
    ExamQuestion(
      id: 'gen_197',
      type: 'general',
      text:
          'What kind of situations require you to be extra attentive to small details?',
    ),
    ExamQuestion(
      id: 'gen_198',
      type: 'general',
      text:
          'Describe a time when you helped solve a problem before anyone asked.',
    ),
    ExamQuestion(
      id: 'gen_199',
      type: 'general',
      text:
          'How do you usually deal with unclear instructions from others?',
    ),
    ExamQuestion(
      id: 'gen_200',
      type: 'general',
      text:
          'What do you think passengers expect the most from a professional crew member?',
    ),
    ExamQuestion(
      id: 'gen_201',
      type: 'general',
      text:
          'Describe a time you communicated bad news in a sensitive way.',
    ),
    ExamQuestion(
      id: 'gen_202',
      type: 'general',
      text:
          'How do you react when you feel unfairly judged in a group setting?',
    ),
    ExamQuestion(
      id: 'gen_203',
      type: 'general',
      text:
          'What techniques help you stay calm during unexpected changes?',
    ),
    ExamQuestion(
      id: 'gen_204',
      type: 'general',
      text:
          'Tell me about a moment when you resolved a misunderstanding between two people.',
    ),
    ExamQuestion(
      id: 'gen_205',
      type: 'general',
      text:
          'How do you adjust your tone when giving instructions to different types of people?',
    ),
    ExamQuestion(
      id: 'gen_206',
      type: 'general',
      text:
          'What do you think is the best way to encourage cooperation in a team?',
    ),
    ExamQuestion(
      id: 'gen_207',
      type: 'general',
      text:
          'Describe a situation where you needed to act calmly while others were panicking.',
    ),
    ExamQuestion(
      id: 'gen_208',
      type: 'general',
      text:
          'How do you maintain professionalism when dealing with humorous or sarcastic people?',
    ),
    ExamQuestion(
      id: 'gen_209',
      type: 'general',
      text:
          'Tell me about a time you offered support to someone without knowing them well.',
    ),
    ExamQuestion(
      id: 'gen_210',
      type: 'general',
      text:
          'How do you control nervousness before an important responsibility?',
    ),
    ExamQuestion(
      id: 'gen_211',
      type: 'general',
      text:
          'What methods do you use to improve your speaking confidence in English?',
    ),
    ExamQuestion(
      id: 'gen_212',
      type: 'general',
      text:
          'Describe a moment where you had to multitask under pressure.',
    ),
    ExamQuestion(
      id: 'gen_213',
      type: 'general',
      text:
          'How do you maintain politeness when dealing with uncooperative passengers?',
    ),
    ExamQuestion(
      id: 'gen_214',
      type: 'general',
      text:
          'Tell me about a time when you handled a stressful situation better than you expected.',
    ),
    ExamQuestion(
      id: 'gen_215',
      type: 'general',
      text:
          'How important is it for you to stay composed in front of others?',
    ),
    ExamQuestion(
      id: 'gen_216',
      type: 'general',
      text:
          'What do you think makes communication effective in emergency situations?',
    ),
    ExamQuestion(
      id: 'gen_217',
      type: 'general',
      text:
          'Describe a time you voluntarily took responsibility for something important.',
    ),
    ExamQuestion(
      id: 'gen_218',
      type: 'general',
      text:
          'What do you think is the most challenging type of passenger behaviour?',
    ),
    ExamQuestion(
      id: 'gen_219',
      type: 'general',
      text:
          'How do you stay professional when you feel emotionally affected by a situation?',
    ),
    ExamQuestion(
      id: 'gen_220',
      type: 'general',
      text:
          'Describe how you would explain a complex safety instruction in a simple and friendly manner.',
    ),
    ExamQuestion(
      id: 'gen_221',
      type: 'general',
      text: 'Describe a moment when you had to stay patient for someone who was very stressed.',
    ),
    ExamQuestion(
      id: 'gen_222',
      type: 'general',
      text: 'What do you think is the biggest communication mistake people make during conflicts?',
    ),
    ExamQuestion(
      id: 'gen_223',
      type: 'general',
      text: 'Tell me about a time you solved a problem by observing a small detail.',
    ),
    ExamQuestion(
      id: 'gen_224',
      type: 'general',
      text: 'How do you react when someone misunderstands your intentions?',
    ),
    ExamQuestion(
      id: 'gen_225',
      type: 'general',
      text: 'Describe a time you took initiative in a group task.',
    ),
    ExamQuestion(
      id: 'gen_226',
      type: 'general',
      text: 'What have you learned about staying calm in stressful environments?',
    ),
    ExamQuestion(
      id: 'gen_227',
      type: 'general',
      text: 'Tell me about a time when multitasking was essential.',
    ),
    ExamQuestion(
      id: 'gen_228',
      type: 'general',
      text: 'How do you adjust your behaviour when working with older people?',
    ),
    ExamQuestion(
      id: 'gen_229',
      type: 'general',
      text: 'Describe a moment when someone trusted you with an important task.',
    ),
    ExamQuestion(
      id: 'gen_230',
      type: 'general',
      text: 'How do you stay positive during long and exhausting days?',
    ),
    ExamQuestion(
      id: 'gen_231',
      type: 'general',
      text: 'Tell me about a time you supported someone emotionally.',
    ),
    ExamQuestion(
      id: 'gen_232',
      type: 'general',
      text: 'How do you handle people who constantly interrupt?',
    ),
    ExamQuestion(
      id: 'gen_233',
      type: 'general',
      text: 'What role does kindness play in customer-facing jobs?',
    ),
    ExamQuestion(
      id: 'gen_234',
      type: 'general',
      text: 'Describe a time you had to think quickly and act immediately.',
    ),
    ExamQuestion(
      id: 'gen_235',
      type: 'general',
      text: 'How do you stay organised during chaotic situations?',
    ),
    ExamQuestion(
      id: 'gen_236',
      type: 'general',
      text: 'Tell me about a time when listening carefully helped you avoid a mistake.',
    ),
    ExamQuestion(
      id: 'gen_237',
      type: 'general',
      text: 'How do you keep your emotions under control when people test your patience?',
    ),
    ExamQuestion(
      id: 'gen_238',
      type: 'general',
      text: 'Why is teamwork sometimes difficult? Give an example from your life.',
    ),
    ExamQuestion(
      id: 'gen_239',
      type: 'general',
      text: 'Describe a time when you showed leadership without holding a formal title.',
    ),
    ExamQuestion(
      id: 'gen_240',
      type: 'general',
      text: 'How do you clarify something when you realise someone didn’t understand you?',
    ),
    ExamQuestion(
      id: 'gen_241',
      type: 'general',
      text: 'Tell me about a time you needed to be extra supportive to someone anxious.',
    ),
    ExamQuestion(
      id: 'gen_242',
      type: 'general',
      text: 'How do you stay fair and neutral when people disagree?',
    ),
    ExamQuestion(
      id: 'gen_243',
      type: 'general',
      text: 'Describe a time when you turned a negative situation into a positive one.',
    ),
    ExamQuestion(
      id: 'gen_244',
      type: 'general',
      text: 'What do you do when someone blames you unfairly?',
    ),
    ExamQuestion(
      id: 'gen_245',
      type: 'general',
      text: 'How do you handle people who speak too fast in English?',
    ),
    ExamQuestion(
      id: 'gen_246',
      type: 'general',
      text: 'Tell me about a time when you had to speak confidently even if you felt nervous.',
    ),
    ExamQuestion(
      id: 'gen_247',
      type: 'general',
      text: 'How do you react when schedules suddenly change?',
    ),
    ExamQuestion(
      id: 'gen_248',
      type: 'general',
      text: 'What do you think is the key to staying calm during emergencies?',
    ),
    ExamQuestion(
      id: 'gen_249',
      type: 'general',
      text: 'Describe a time you stayed patient even when someone was disrespectful.',
    ),
    ExamQuestion(
      id: 'gen_250',
      type: 'general',
      text: 'What methods do you use to understand people with different accents?',
    ),
    ExamQuestion(
      id: 'gen_251',
      type: 'general',
      text: 'How do you ensure you look professional even when tired?',
    ),
    ExamQuestion(
      id: 'gen_252',
      type: 'general',
      text: 'Tell me about a moment when you helped a group function better.',
    ),
    ExamQuestion(
      id: 'gen_253',
      type: 'general',
      text: 'What do you do when communication becomes confusing?',
    ),
    ExamQuestion(
      id: 'gen_254',
      type: 'general',
      text: 'Describe a time when you supported someone in a high-pressure moment.',
    ),
    ExamQuestion(
      id: 'gen_255',
      type: 'general',
      text: 'How do you react when someone raises their voice?',
    ),
    ExamQuestion(
      id: 'gen_256',
      type: 'general',
      text: 'What is your strategy to stay confident in long interviews?',
    ),
    ExamQuestion(
      id: 'gen_257',
      type: 'general',
      text: 'Tell me about a moment when your calmness helped others calm down.',
    ),
    ExamQuestion(
      id: 'gen_258',
      type: 'general',
      text: 'How would you describe your biggest strength in communication?',
    ),
    ExamQuestion(
      id: 'gen_259',
      type: 'general',
      text: 'Describe a time when you needed to comfort someone who was crying.',
    ),
    ExamQuestion(
      id: 'gen_260',
      type: 'general',
      text: 'What have you learned from stressful life experiences?',
    ),
    ExamQuestion(
      id: 'gen_261',
      type: 'general',
      text: 'Tell me about a time when you made someone feel safe and supported.',
    ),
    ExamQuestion(
      id: 'gen_262',
      type: 'general',
      text: 'How do you adjust when working with someone who has a very strong personality?',
    ),
    ExamQuestion(
      id: 'gen_263',
      type: 'general',
      text: 'Describe a time when you remained professional despite being upset.',
    ),
    ExamQuestion(
      id: 'gen_264',
      type: 'general',
      text: 'What do you do to stay emotionally balanced during long days?',
    ),
    ExamQuestion(
      id: 'gen_265',
      type: 'general',
      text: 'Tell me about a time when you helped two people solve a disagreement.',
    ),
    ExamQuestion(
      id: 'gen_266',
      type: 'general',
      text: 'How do you communicate with someone who seems nervous or shy?',
    ),
    ExamQuestion(
      id: 'gen_267',
      type: 'general',
      text: 'Describe a moment when you needed to be especially attentive.',
    ),
    ExamQuestion(
      id: 'gen_268',
      type: 'general',
      text: 'What do you think is the biggest key to trust in teamwork?',
    ),
    ExamQuestion(
      id: 'gen_269',
      type: 'general',
      text: 'Tell me about a time when you handled uncertainty well.',
    ),
    ExamQuestion(
      id: 'gen_270',
      type: 'general',
      text: 'How do you respond when someone complains unfairly?',
    ),
    ExamQuestion(
      id: 'gen_271',
      type: 'general',
      text: 'Describe a time when you had to apologise on behalf of someone else.',
    ),
    ExamQuestion(
      id: 'gen_272',
      type: 'general',
      text: 'How do you stay respectful when someone is irritated?',
    ),
    ExamQuestion(
      id: 'gen_273',
      type: 'general',
      text: 'Tell me about a moment when you explained something clearly even under pressure.',
    ),
    ExamQuestion(
      id: 'gen_274',
      type: 'general',
      text: 'How do you manage stress when many people rely on you?',
    ),
    ExamQuestion(
      id: 'gen_275',
      type: 'general',
      text: 'What do you do when someone keeps asking the same question repeatedly?',
    ),
    ExamQuestion(
      id: 'gen_276',
      type: 'general',
      text: 'Describe a time you adjusted your approach after realising someone was sensitive.',
    ),
    ExamQuestion(
      id: 'gen_277',
      type: 'general',
      text: 'How do you deal with situations where you feel overwhelmed?',
    ),
    ExamQuestion(
      id: 'gen_278',
      type: 'general',
      text: 'Tell me about a moment you encouraged someone who lacked confidence.',
    ),
    ExamQuestion(
      id: 'gen_279',
      type: 'general',
      text: 'What is the best way to maintain a pleasant atmosphere around others?',
    ),
    ExamQuestion(
      id: 'gen_280',
      type: 'general',
      text: 'Describe a time when you communicated something difficult in a gentle way.',
    ),






  ];


  // ==========================
// GÖRSEL SORULAR (100 ADET)
// ==========================
// ==========================
// GÖRSEL SORULAR (100 ADET)
// ==========================

// Tüm image soruları için ortak prompt
static const String imageQuestionPrompt =
    'Describe this picture in detail, mentioning everything you can see: '
    'the place, the people (if any), their expressions, their body language, '
    'and the surroundings.';

// assets/pexels_images klasöründe kaç tane img_X.jpg olduğunu burada belirt
// Şu an sende 80 görsel var: img_1.jpg ... img_80.jpg
static const int _localImageCount = 80;

// Verilen index için uygun asset yolunu döndürür.
// 1.._localImageCount arası direkt kullanılır,
// üstü gelirse (81-100 gibi) 1-80 arasında döngüsel tekrar eder.
static String _assetPathForImageIndex(int index) {
  final wrappedIndex = ((index - 1) % _localImageCount) + 1;
  return 'assets/pexels_images/img_$wrappedIndex.jpg';
}

// 100 görsel sorusunu dinamik şekilde üret
static final List<ExamQuestion> imageQuestions =
    List<ExamQuestion>.generate(100, (index) {
  final int questionNumber = index + 1;

  return ExamQuestion(
    id: 'img_$questionNumber',
    type: 'image',
    text: imageQuestionPrompt,
    imageUrl: _assetPathForImageIndex(questionNumber),
  );
});
  // ==========================
  // SENARYO SORULARI (20 ADET)
  // ==========================
  static List<ExamQuestion> scenarioQuestions = [
    ExamQuestion(
      id: 'sc_1',
      type: 'scenario',
      text:
          'Your flight is delayed and some passengers are angry. How would you handle this situation?',
    ),
    ExamQuestion(
      id: 'sc_2',
      type: 'scenario',
      text:
          'A passenger is very nervous during turbulence. What would you say and do to help them?',
    ),
    ExamQuestion(
      id: 'sc_3',
      type: 'scenario',
      text:
          'Two passengers are arguing loudly and disturbing others. How would you manage this?',
    ),
    ExamQuestion(
      id: 'sc_4',
      type: 'scenario',
      text:
          'A passenger complains that their special meal is not available anymore. How do you respond?',
    ),
    ExamQuestion(
      id: 'sc_5',
      type: 'scenario',
      text:
          'You see a passenger who looks unwell and is breathing heavily. What would you do?',
    ),
    ExamQuestion(
      id: 'sc_6',
      type: 'scenario',
      text:
          'A passenger refuses to fasten their seatbelt during take-off. How do you handle this?',
    ),
    ExamQuestion(
      id: 'sc_7',
      type: 'scenario',
      text:
          'A child is crying loudly and disturbing other passengers. How would you approach the child and the parents?',
    ),
    ExamQuestion(
      id: 'sc_8',
      type: 'scenario',
      text:
          'A passenger insists on changing seats even though the flight is full. What would you say?',
    ),
    ExamQuestion(
      id: 'sc_9',
      type: 'scenario',
      text:
          'During meal service, a passenger is rude and impatient. How do you keep the situation under control?',
    ),
    ExamQuestion(
      id: 'sc_10',
      type: 'scenario',
      text:
          'You hear a strange smell in the cabin and some passengers are worried. What steps would you follow?',
    ),
    ExamQuestion(
      id: 'sc_11',
      type: 'scenario',
      text:
          'A passenger tells you they are afraid of flying and cannot relax. How would you support them?',
    ),
    ExamQuestion(
      id: 'sc_12',
      type: 'scenario',
      text:
          'A passenger is using their phone during take-off and does not listen to your instructions. What do you do?',
    ),
    ExamQuestion(
      id: 'sc_13',
      type: 'scenario',
      text:
          'You notice a suspicious item left unattended in the cabin. What is your reaction?',
    ),
    ExamQuestion(
      id: 'sc_14',
      type: 'scenario',
      text:
          'A passenger with reduced mobility needs help going to the lavatory. How would you assist while keeping safety and dignity?',
    ),
    ExamQuestion(
      id: 'sc_15',
      type: 'scenario',
      text:
          'There is severe turbulence and service must be stopped. How do you communicate this to passengers?',
    ),
    ExamQuestion(
      id: 'sc_16',
      type: 'scenario',
      text:
          'After landing, a passenger complains that their luggage is missing. How would you explain the procedure?',
    ),
    ExamQuestion(
      id: 'sc_17',
      type: 'scenario',
      text:
          'A passenger is having an allergic reaction to something they ate on board. What steps would you take?',
    ),
    ExamQuestion(
      id: 'sc_18',
      type: 'scenario',
      text:
          'You see two colleagues disagreeing about a safety procedure in front of passengers. What would you do?',
    ),
    ExamQuestion(
      id: 'sc_19',
      type: 'scenario',
      text:
          'A passenger is making inappropriate comments to you or another crew member. How would you handle this professionally?',
    ),
    ExamQuestion(
      id: 'sc_20',
      type: 'scenario',
      text:
          'During an evacuation, some passengers try to take their luggage with them. What should you do and say?',
    ),
        // EK SENARYO SORULARI (21–30)
    ExamQuestion(
      id: 'sc_21',
      type: 'scenario',
      text:
          'A passenger asks for an upgrade to business class although they did not pay for it. How would you respond?',
    ),
    ExamQuestion(
      id: 'sc_22',
      type: 'scenario',
      text:
          'During boarding, a passenger blocks the aisle while searching for their seat. Other passengers are waiting. What would you do?',
    ),
    ExamQuestion(
      id: 'sc_23',
      type: 'scenario',
      text:
          'A family with small children is seated far from each other. They ask you to help them sit together on a full flight. How do you handle this?',
    ),
    ExamQuestion(
      id: 'sc_24',
      type: 'scenario',
      text:
          'You notice a passenger secretly drinking their own alcohol on board. How do you manage this situation?',
    ),
    ExamQuestion(
      id: 'sc_25',
      type: 'scenario',
      text:
          'A passenger claims that another passenger has taken their seat. Both insist they are right. What steps would you take?',
    ),
    ExamQuestion(
      id: 'sc_26',
      type: 'scenario',
      text:
          'During landing, a passenger suddenly stands up to take something from the overhead bin. What do you say and do?',
    ),
    ExamQuestion(
      id: 'sc_27',
      type: 'scenario',
      text:
          'A passenger refuses to follow the no-smoking rule in the lavatory. How would you react and what would you report?',
    ),
    ExamQuestion(
      id: 'sc_28',
      type: 'scenario',
      text:
          'You see a passenger having a panic attack just before take-off. How would you approach and support them?',
    ),
    ExamQuestion(
      id: 'sc_29',
      type: 'scenario',
      text:
          'A passenger with a severe fear of heights insists on keeping the window shade closed at all times, but the safety procedure requires it open for take-off and landing. How do you solve this?',
    ),
    ExamQuestion(
      id: 'sc_30',
      type: 'scenario',
      text:
          'After a hard landing, some passengers are scared and start asking many questions at once. How do you communicate and maintain order?',
    ),
        // EK SENARYO SORULARI (31–50)
    ExamQuestion(
      id: 'sc_31',
      type: 'scenario',
      text:
          'During boarding, a passenger loudly complains about the seat they received and starts to influence other passengers. How would you handle the situation?',
    ),
    ExamQuestion(
      id: 'sc_32',
      type: 'scenario',
      text:
          'A passenger tells you they have lost their passport somewhere on board. What steps would you take and how would you communicate with them?',
    ),
    ExamQuestion(
      id: 'sc_33',
      type: 'scenario',
      text:
          'You notice that a passenger looks very pale and dizzy during take-off. What actions would you take as cabin crew?',
    ),
    ExamQuestion(
      id: 'sc_34',
      type: 'scenario',
      text:
          'Two passengers are speaking very loudly in the night and disturbing others who are trying to sleep. How do you approach them?',
    ),
    ExamQuestion(
      id: 'sc_35',
      type: 'scenario',
      text:
          'A passenger insists on keeping their large bag near their feet instead of putting it in the overhead bin. How would you explain the safety risk?',
    ),
    ExamQuestion(
      id: 'sc_36',
      type: 'scenario',
      text:
          'During turbulence, a passenger stands up to use the lavatory despite the seatbelt sign. What do you say and do?',
    ),
    ExamQuestion(
      id: 'sc_37',
      type: 'scenario',
      text:
          'A passenger is upset because their in-flight entertainment system is not working. How would you respond and offer alternatives?',
    ),
    ExamQuestion(
      id: 'sc_38',
      type: 'scenario',
      text:
          'You observe a passenger who seems to be under the influence of alcohol and behaves loudly. How would you manage the situation safely?',
    ),
    ExamQuestion(
      id: 'sc_39',
      type: 'scenario',
      text:
          'A passenger with a fear of flying asks to sit close to a crew member for comfort, but there are no spare seats. What would you say and do?',
    ),
    ExamQuestion(
      id: 'sc_40',
      type: 'scenario',
      text:
          'During disembarkation, a passenger is angry about the delay and blames the crew personally. How do you handle this conversation?',
    ),
    ExamQuestion(
      id: 'sc_41',
      type: 'scenario',
      text:
          'A passenger informs you about a strong allergic reaction risk to nuts, but another passenger has opened a packet next to them. How do you react?',
    ),
    ExamQuestion(
      id: 'sc_42',
      type: 'scenario',
      text:
          'You find a passenger sleeping with their seat fully reclined during meal service, blocking the person behind them. How do you manage this politely?',
    ),
    ExamQuestion(
      id: 'sc_43',
      type: 'scenario',
      text:
          'A passenger refuses to participate in the safety demonstration and jokes about it. How would you respond as a professional cabin crew member?',
    ),
    ExamQuestion(
      id: 'sc_44',
      type: 'scenario',
      text:
          'During the flight, you hear two passengers speaking aggressively in a language you do not fully understand. What steps do you take?',
    ),
    ExamQuestion(
      id: 'sc_45',
      type: 'scenario',
      text:
          'A passenger asks you to keep an eye on their child while they go to the lavatory, but you are busy with service. How would you respond?',
    ),
    ExamQuestion(
      id: 'sc_46',
      type: 'scenario',
      text:
          'You notice smoke coming from a lavatory. What are your immediate actions and how would you communicate with the passengers?',
    ),
    ExamQuestion(
      id: 'sc_47',
      type: 'scenario',
      text:
          'A passenger becomes very emotional and starts crying quietly during the flight. How would you approach and support them?',
    ),
    ExamQuestion(
      id: 'sc_48',
      type: 'scenario',
      text:
          'During boarding, you realise that two passengers with the same seat number have been checked in. How do you manage seat reassignment and communication?',
    ),
    ExamQuestion(
      id: 'sc_49',
      type: 'scenario',
      text:
          'A frequent flyer passenger insists that “they always do it this way” and refuses to follow a new procedure. How would you respond?',
    ),
    ExamQuestion(
      id: 'sc_50',
      type: 'scenario',
      text:
          'During an unexpected go-around (aborted landing), passengers are anxious and confused. What would you announce and how would you calm them?',
    ),
        // EK SENARYO SORULARI (51–70)
    ExamQuestion(
      id: 'sc_51',
      type: 'scenario',
      text:
          'During take-off, a passenger suddenly panics and tries to unfasten their seatbelt. What do you do?',
    ),
    ExamQuestion(
      id: 'sc_52',
      type: 'scenario',
      text:
          'A passenger claims they were promised a window seat but received an aisle seat. How would you resolve this?',
    ),
    ExamQuestion(
      id: 'sc_53',
      type: 'scenario',
      text:
          'A passenger spills a hot drink on themselves and starts panicking. What actions should you take?',
    ),
    ExamQuestion(
      id: 'sc_54',
      type: 'scenario',
      text:
          'During meal service, a passenger refuses the meal due to allergies and demands something else unavailable. How do you respond?',
    ),
    ExamQuestion(
      id: 'sc_55',
      type: 'scenario',
      text:
          'A passenger is filming other passengers without permission. How would you handle this?',
    ),
    ExamQuestion(
      id: 'sc_56',
      type: 'scenario',
      text:
          'Two passengers are arguing about reclining the seat. How would you intervene?',
    ),
    ExamQuestion(
      id: 'sc_57',
      type: 'scenario',
      text:
          'A passenger is extremely anxious after hearing unexpected engine noise. What would you explain?',
    ),
    ExamQuestion(
      id: 'sc_58',
      type: 'scenario',
      text:
          'A passenger refuses to store their laptop for landing and insists they need it. What do you say?',
    ),
    ExamQuestion(
      id: 'sc_59',
      type: 'scenario',
      text:
          'During turbulence, a passenger starts shouting loudly and frightening others. How do you manage this?',
    ),
    ExamQuestion(
      id: 'sc_60',
      type: 'scenario',
      text:
          'A parent leaves a young child unattended while walking around the cabin. What actions should you take?',
    ),
    ExamQuestion(
      id: 'sc_61',
      type: 'scenario',
      text:
          'A passenger claims that another passenger smells bad and demands a seat change. How do you handle this sensitively?',
    ),
    ExamQuestion(
      id: 'sc_62',
      type: 'scenario',
      text:
          'You notice a passenger taking medication and looking unwell. What steps do you take?',
    ),
    ExamQuestion(
      id: 'sc_63',
      type: 'scenario',
      text:
          'A passenger loudly argues with ground staff during boarding and carries the argument on board. What do you do?',
    ),
    ExamQuestion(
      id: 'sc_64',
      type: 'scenario',
      text:
          'A passenger wants to store a large musical instrument in the cabin and refuses to check it in. How do you resolve this?',
    ),
    ExamQuestion(
      id: 'sc_65',
      type: 'scenario',
      text:
          'A passenger believes their seat neighbour is intoxicated and complains. What actions should you take?',
    ),
    ExamQuestion(
      id: 'sc_66',
      type: 'scenario',
      text:
          'A passenger presses the call button repeatedly for non-urgent requests. How would you handle this politely?',
    ),
    ExamQuestion(
      id: 'sc_67',
      type: 'scenario',
      text:
          'You notice two passengers exchanging angry looks and whispering aggressively. How do you prevent escalation?',
    ),
    ExamQuestion(
      id: 'sc_68',
      type: 'scenario',
      text:
          'During descent, a passenger claims their ears hurt badly and starts panicking. What would you advise?',
    ),
    ExamQuestion(
      id: 'sc_69',
      type: 'scenario',
      text:
          'A passenger refuses to put their pet carrier under the seat even after being instructed. What steps do you follow?',
    ),
    ExamQuestion(
      id: 'sc_70',
      type: 'scenario',
      text:
          'A passenger shouts at a crew member claiming the flight duration was not what they expected. How would you de-escalate?',
    ),
        // EK SENARYO SORULARI (71–100)
    ExamQuestion(
      id: 'sc_71',
      type: 'scenario',
      text: 'A passenger starts crying during take-off due to fear. How would you calm them?',
    ),
    ExamQuestion(
      id: 'sc_72',
      type: 'scenario',
      text: 'During landing, a passenger suddenly stands up to retrieve a bag. What do you do?',
    ),
    ExamQuestion(
      id: 'sc_73',
      type: 'scenario',
      text: 'Two passengers fight over a window shade being open or closed. How would you resolve this?',
    ),
    ExamQuestion(
      id: 'sc_74',
      type: 'scenario',
      text: 'A passenger refuses to pay for an item but insists on taking it. What do you say?',
    ),
    ExamQuestion(
      id: 'sc_75',
      type: 'scenario',
      text: 'A passenger says they feel dizzy and faint. What steps do you follow?',
    ),
    ExamQuestion(
      id: 'sc_76',
      type: 'scenario',
      text: 'A parent leaves a baby unattended in the seat while going to the lavatory. How do you respond?',
    ),
    ExamQuestion(
      id: 'sc_77',
      type: 'scenario',
      text: 'A passenger keeps pressing the call button to complain about minor issues. How do you manage politely?',
    ),
    ExamQuestion(
      id: 'sc_78',
      type: 'scenario',
      text: 'A passenger is angry because their entertainment screen is broken. What do you say?',
    ),
    ExamQuestion(
      id: 'sc_79',
      type: 'scenario',
      text: 'You see two passengers exchanging threatening looks. How would you prevent escalation?',
    ),
    ExamQuestion(
      id: 'sc_80',
      type: 'scenario',
      text: 'A passenger believes another is taking photos of them. How do you handle this calmly?',
    ),
    ExamQuestion(
      id: 'sc_81',
      type: 'scenario',
      text: 'A passenger demands to switch seats with someone who refuses. How would you mediate?',
    ),
    ExamQuestion(
      id: 'sc_82',
      type: 'scenario',
      text: 'A passenger begins to panic after hearing a loud mechanical sound. What explanation do you give?',
    ),
    ExamQuestion(
      id: 'sc_83',
      type: 'scenario',
      text: 'During meal service, turbulence increases and items fall. How do you control the situation?',
    ),
    ExamQuestion(
      id: 'sc_84',
      type: 'scenario',
      text: 'A child keeps kicking the seat in front. Both families complain. How do you resolve it?',
    ),
    ExamQuestion(
      id: 'sc_85',
      type: 'scenario',
      text: 'A passenger says they lost their medication and begins to panic. What do you do?',
    ),
    ExamQuestion(
      id: 'sc_86',
      type: 'scenario',
      text: 'A passenger tries to open the overhead bin during turbulence. How do you react?',
    ),
    ExamQuestion(
      id: 'sc_87',
      type: 'scenario',
      text: 'A very tall passenger is uncomfortable and asks for a seat change on a full flight. What is your response?',
    ),
    ExamQuestion(
      id: 'sc_88',
      type: 'scenario',
      text: 'A passenger refuses to participate in the safety briefing. How do you manage this professionally?',
    ),
    ExamQuestion(
      id: 'sc_89',
      type: 'scenario',
      text: 'Two passengers accuse each other of stealing a phone. How do you proceed?',
    ),
    ExamQuestion(
      id: 'sc_90',
      type: 'scenario',
      text: 'A passenger becomes claustrophobic mid-flight. How do you support them?',
    ),
    ExamQuestion(
      id: 'sc_91',
      type: 'scenario',
      text: 'A passenger with a pet becomes emotional because the pet is stressed. What do you do?',
    ),
    ExamQuestion(
      id: 'sc_92',
      type: 'scenario',
      text: 'A passenger faints briefly during cruise. What is your protocol?',
    ),
    ExamQuestion(
      id: 'sc_93',
      type: 'scenario',
      text: 'A passenger complains loudly about food quality and disturbs others. How do you handle it?',
    ),
    ExamQuestion(
      id: 'sc_94',
      type: 'scenario',
      text: 'A passenger refuses to switch their mobile phone to flight mode. What steps do you take?',
    ),
    ExamQuestion(
      id: 'sc_95',
      type: 'scenario',
      text: 'A passenger starts yelling about a missing suitcase before landing. How do you respond?',
    ),
    ExamQuestion(
      id: 'sc_96',
      type: 'scenario',
      text: 'A passenger insists on checking the cockpit door. What do you do?',
    ),
    ExamQuestion(
      id: 'sc_97',
      type: 'scenario',
      text: 'A passenger becomes aggressive after drinking alcohol. How do you manage the situation safely?',
    ),
    ExamQuestion(
      id: 'sc_98',
      type: 'scenario',
      text: 'Two families argue about seating arrangements. How do you mediate professionally?',
    ),
    ExamQuestion(
      id: 'sc_99',
      type: 'scenario',
      text: 'A passenger panics because the cabin lights change suddenly. What explanation do you offer?',
    ),
    ExamQuestion(
      id: 'sc_100',
      type: 'scenario',
      text: 'A passenger sees another hiding something under a seat and complains. How do you respond?',
    ),




  ];
    // =====================================================
  // Yardımcı: Listeden rastgele N soru seç
  // =====================================================
  static List<ExamQuestion> _pickRandom(
      List<ExamQuestion> source, int count, Random rnd) {
    if (source.isEmpty || count <= 0) return [];

    // Listeyi kopyalayıp karıştırıyoruz
    final copy = List<ExamQuestion>.from(source);
    copy.shuffle(rnd);

    if (count >= copy.length) {
      return copy;
    }
    return copy.take(count).toList();
  }

  // =====================================================
  // Dışarıdan kullanılacak ana fonksiyon: generateExam
  // =====================================================
  static List<ExamQuestion> generateExam({
    int introCount = 2,
    int generalCount = 10,
    int imageCount = 5,
    int scenarioCount = 5,
  }) {
    final rnd = Random();
    final List<ExamQuestion> exam = [];

    // 1) Intro soruları: genelde sabit başta dursun
    final intro = introQuestions.take(introCount).toList();
    exam.addAll(intro);

    // 2) Diğer tiplerden rastgele seçim
    exam.addAll(_pickRandom(generalQuestions, generalCount, rnd));
    exam.addAll(_pickRandom(imageQuestions, imageCount, rnd));
    exam.addAll(_pickRandom(scenarioQuestions, scenarioCount, rnd));

    // 3) Intro soruları başta sabit kalsın, geri kalan karışsın
    final rest = exam.skip(intro.length).toList();
    rest.shuffle(rnd);

    return [...intro, ...rest];
  }
}


