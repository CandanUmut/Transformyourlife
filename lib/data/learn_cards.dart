import 'models/learn_card.dart';

final learnCards = <LearnCard>[
  LearnCard(
    id: 'habit_loop',
    title: 'Habit loop: cue → routine → reward',
    category: 'Habits 101',
    body:
        'Notice the small signal that precedes your behavior. Pair it with a routine that takes 30–60 seconds and ends with a tiny reward like a deep breath or a smile.',
    tryThis: 'Pick one cue like “after I brush my teeth” and attach a 30-second routine to it today.',
  ),
  LearnCard(
    id: 'tiny_habits',
    title: 'Start tiny, design the environment',
    category: 'Habits 101',
    body:
        'Shrink the habit until it feels almost too easy. Then make the environment obvious: leave water on the desk, shoes by the door, journal open on the table.',
    tryThis: 'Set up one physical reminder for a habit before you go to bed.',
  ),
  LearnCard(
    id: 'halt',
    title: 'When urges spike, check HALT',
    category: 'Urges',
    body:
        'Hungry, Angry, Lonely, Tired — these states make urges louder. Naming them gives you options: drink water, text a friend, take three breaths, stretch.',
    tryThis: 'When an urge appears today, pause and ask: am I hungry, angry, lonely, or tired?',
  ),
  LearnCard(
    id: 'identity',
    title: 'I am becoming…',
    category: 'Identity',
    body:
        'Identity statements remind you why you show up. Speak to yourself with kindness: “I am becoming someone who chooses clarity over impulse.”',
    tryThis: 'Write one identity line in your notes and read it before bed.',
  ),
  LearnCard(
    id: 'slips',
    title: 'Slips are data, not destiny',
    category: 'Urges',
    body:
        'A slip is a signal, not a verdict. Notice what led up to it, log it honestly, and plan one tiny supportive action for the next 24 hours.',
    tryThis: 'After a slip, pick one tiny stabilizer: drink water, go for a 5‑minute walk, or send a message to someone safe.',
  ),
];
