// Full CBT thought record. The original ThoughtEntry stays as a quick-log;
// this is the structured therapeutic version (situation → automatic thought
// → distortion → evidence → reframe → outcome) that therapists actually
// prescribe.

class ThoughtRecord {
  final String id;
  final DateTime date;
  final String situation;
  final String automaticThought;
  final List<String> distortions; // codes from CognitiveDistortion.code
  final String evidenceFor;
  final String evidenceAgainst;
  final String reframe;
  final int? moodBefore; // 1–10
  final int? moodAfter; // 1–10

  const ThoughtRecord({
    required this.id,
    required this.date,
    required this.situation,
    required this.automaticThought,
    required this.distortions,
    required this.evidenceFor,
    required this.evidenceAgainst,
    required this.reframe,
    this.moodBefore,
    this.moodAfter,
  });

  factory ThoughtRecord.fromJson(Map<String, dynamic> j) => ThoughtRecord(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        situation: j['situation'] as String? ?? '',
        automaticThought: j['automaticThought'] as String? ?? '',
        distortions: ((j['distortions'] as List<dynamic>?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        evidenceFor: j['evidenceFor'] as String? ?? '',
        evidenceAgainst: j['evidenceAgainst'] as String? ?? '',
        reframe: j['reframe'] as String? ?? '',
        moodBefore: (j['moodBefore'] as num?)?.toInt(),
        moodAfter: (j['moodAfter'] as num?)?.toInt(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'situation': situation,
        'automaticThought': automaticThought,
        'distortions': distortions,
        'evidenceFor': evidenceFor,
        'evidenceAgainst': evidenceAgainst,
        'reframe': reframe,
        if (moodBefore != null) 'moodBefore': moodBefore,
        if (moodAfter != null) 'moodAfter': moodAfter,
      };
}

class CognitiveDistortion {
  final String code;
  final String name;
  final String description;
  final String reframePrompt;
  const CognitiveDistortion({
    required this.code,
    required this.name,
    required this.description,
    required this.reframePrompt,
  });

  static const all = <CognitiveDistortion>[
    CognitiveDistortion(
      code: 'all_or_nothing',
      name: 'All-or-nothing',
      description:
          'Seeing things in black and white — anything less than perfect is failure.',
      reframePrompt: 'Where on the spectrum is the truth actually sitting?',
    ),
    CognitiveDistortion(
      code: 'catastrophizing',
      name: 'Catastrophizing',
      description:
          'Expecting the worst possible outcome and treating it as certain.',
      reframePrompt:
          'What is the most likely outcome, not the worst possible one?',
    ),
    CognitiveDistortion(
      code: 'overgeneralization',
      name: 'Overgeneralization',
      description: 'One bad event becomes a never-ending pattern of defeat.',
      reframePrompt:
          'Is this really "always" / "never," or is it just this once?',
    ),
    CognitiveDistortion(
      code: 'mind_reading',
      name: 'Mind reading',
      description: 'Assuming you know what others are thinking about you.',
      reframePrompt: 'What evidence do I actually have for that assumption?',
    ),
    CognitiveDistortion(
      code: 'should',
      name: '"Should" statements',
      description:
          'Beating yourself up with "should," "must," "ought to." Drives shame.',
      reframePrompt:
          'Replace "I should" with "I would like to" — does it land softer?',
    ),
    CognitiveDistortion(
      code: 'emotional_reasoning',
      name: 'Emotional reasoning',
      description: 'Believing something is true because it FEELS true.',
      reframePrompt: 'Feelings are data, not verdicts. What do the facts say?',
    ),
    CognitiveDistortion(
      code: 'personalization',
      name: 'Personalization',
      description:
          'Blaming yourself for things that aren\'t entirely your fault.',
      reframePrompt: 'What other factors contributed — was this all on me?',
    ),
    CognitiveDistortion(
      code: 'mental_filter',
      name: 'Mental filter',
      description:
          'Focusing only on the negative and screening out the positive.',
      reframePrompt: 'What good has happened today that I\'m discounting?',
    ),
    CognitiveDistortion(
      code: 'labeling',
      name: 'Labeling',
      description:
          'Attaching a global label to yourself: "I\'m a failure," "I\'m broken."',
      reframePrompt:
          'Separate the behaviour from the person. What would I tell a friend?',
    ),
    CognitiveDistortion(
      code: 'disqualifying_positive',
      name: 'Disqualifying the positive',
      description: 'Telling yourself good things "don\'t count."',
      reframePrompt: 'Why would that achievement count if a friend did it?',
    ),
  ];

  static CognitiveDistortion? byCode(String code) {
    for (final d in all) {
      if (d.code == code) return d;
    }
    return null;
  }
}
