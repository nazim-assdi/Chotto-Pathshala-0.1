# Gyanbari Curriculum Scope Map

This is the planned scope for original learning content. It is a development map, not a statement that every item is already available in the app.

## Playgroup — explore and name

| Strand | Intended learning outcomes |
|---|---|
| Bangla | Listen and respond; recognise familiar sounds and selected letters; build everyday vocabulary; enjoy oral stories and picture talk |
| English | Understand classroom greetings and simple instructions; recognise selected alphabet letters; connect familiar words to pictures |
| Mathematics | Sort by colour, shape and size; match objects; compare more/less; experience counting small groups; recognise simple patterns |
| Environment and science | Name family members, body parts, familiar animals, plants, weather and everyday objects; notice simple similarities and differences |
| Arabic / Islamic and values | Meet Arabic letters through visual recognition and careful listening; learn simple manners, kindness, gratitude and respect |
| Creative and physical | Scribble, colour, sing or rhythm-play with licensed material, move safely, use simple hand-control activities |
| Health and safety | Practise handwashing, safe food habits, trusted-adult awareness and holding an adult's hand near roads |

## Nursery — recognise and connect

| Strand | Intended learning outcomes |
|---|---|
| Bangla | Identify more letters and sounds; connect sounds to familiar words; retell a short picture sequence; develop pencil control |
| English | Recognise most alphabet forms; learn everyday vocabulary; use simple greetings and short oral phrases |
| Mathematics | Count and compare small sets; recognise numerals; sort and extend patterns; identify basic 2D shapes; compare length and quantity |
| Environment and science | Describe needs of people, plants and animals; observe weather; identify common materials and senses; discuss care for surroundings |
| Arabic / Islamic and values | Recognise additional Arabic letters; practise reviewed pronunciation; understand everyday manners and age-appropriate values |
| Creative and physical | Draw purposeful shapes; follow movement sequences; make simple crafts; express feelings through art and talk |
| Health and safety | Explain basic hygiene; identify safe and unsafe situations; name feelings and ask trusted adults for help |

## KG — build foundations

| Strand | Intended learning outcomes |
|---|---|
| Bangla | Strengthen letter-sound awareness; blend simple syllables and words; read familiar words; write letters and short words |
| English | Develop phonics readiness; connect common letter sounds and words; read familiar labels; write simple words and phrases |
| Mathematics | Read and order numbers; compare quantities; solve simple addition/subtraction with objects and pictures; explore time, money and measurement language |
| Environment and science | Classify living/non-living things; describe plant and animal needs; observe day/night and weather; make simple predictions |
| Arabic / Islamic and values | Recognise and distinguish Arabic letters; practise short, reviewed reading tasks; apply manners and values in daily scenarios |
| Creative and physical | Follow multi-step craft directions; create patterns and pictures; build coordination and teamwork |
| Health and safety | Describe hygiene routines, balanced food choices, road safety and simple emergency help-seeking |

## Class One — apply and explain

| Strand | Intended learning outcomes |
|---|---|
| Bangla | Read age-appropriate words and short passages; understand meaning; form sentences; practise spelling and basic writing |
| English | Read and understand simple sentences; use basic vocabulary and grammar in context; write short descriptions and answers |
| Mathematics | Understand place value foundations; add and subtract within the taught range; solve simple word problems; identify shapes and use basic measurement |
| Environment and science | Observe and describe local plants, animals, water, weather, materials and the human body; explain simple cause-and-effect relationships |
| Arabic / Islamic and values | Read age-appropriate Arabic letter combinations; reinforce reviewed pronunciation; understand selected manners and moral lessons |
| Creative and physical | Complete guided art/design tasks; describe creative choices; practise cooperation, movement and fair play |
| Health and safety | Apply hygiene, nutrition, personal-boundary, road and home-safety rules in simple scenarios |

## Lesson and assessment design

Each topic should progress through:
1. **See it:** a clear, relevant illustration or real-world example.
2. **Hear it:** optional narration with the correct language selected for each segment.
3. **Say it:** child repeats or describes the idea.
4. **Try it:** guided, hands-on or picture-based activity.
5. **Show it:** a short question, match, sort, sequence or explanation.
6. **Review it:** feedback explains why an answer is correct.

## Content metadata standard

New lesson records should retain the existing JSON fields and may add:
- `learning_outcomes`: list of observable outcomes.
- `prerequisite_ids`: earlier lessons needed.
- `language_segments`: explicit text and BCP-47 language code, such as `bn-BD`, `en-US` or `ar-SA`.
- `image_assets`: asset identifier, alt text, source/licence and review status.
- `activity_type`: matching, sorting, tracing, sequencing, observation or oral response.
- `difficulty`: age-appropriate level within the grade.
- `review_status`: draft, content-reviewed, language-reviewed or approved.

Quiz records should include a stable unique ID, one unambiguous answer, plausible age-appropriate distractors, an explanation and a learning-outcome tag.

## Quality gates before release

- A teacher or subject reviewer checks accuracy and developmental suitability.
- A Bangla/English/Arabic language reviewer checks spelling, pronunciation and phrasing.
- Images are checked for accurate representation, child safety, relevance, accessibility text and licence.
- Quiz answer keys are validated programmatically and manually sampled.
- Audio is tested on supported and unsupported devices, including offline mode.
- Existing lesson IDs and quiz IDs are preserved when content is revised.
