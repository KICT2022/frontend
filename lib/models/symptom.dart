class SymptomCategory {
  final String id;
  final String name;
  final String description;
  final List<Symptom> symptoms;

  SymptomCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.symptoms,
  });
}

class Symptom {
  final String id;
  final String name;
  final String description;
  final String categoryId;

  Symptom({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
  });
}

class SymptomData {
  static List<SymptomCategory> getCategories() {
    return [
      SymptomCategory(
        id: 'general',
        name: '전신 증상',
        description: '전체적인 신체 상태와 관련된 증상',
        symptoms: [
          Symptom(
            id: 'fever',
            name: '발열 (열이 남)',
            description: '체온이 정상보다 높은 상태',
            categoryId: 'general',
          ),
          Symptom(
            id: 'chills',
            name: '오한 (몸이 떨림)',
            description: '추위를 느끼며 몸이 떨리는 증상',
            categoryId: 'general',
          ),
          Symptom(
            id: 'fatigue',
            name: '무기력 / 피로감',
            description: '기운이 없고 피곤한 느낌',
            categoryId: 'general',
          ),
          Symptom(
            id: 'loss_of_appetite',
            name: '식욕 저하',
            description: '먹고 싶은 욕구가 줄어든 상태',
            categoryId: 'general',
          ),
          Symptom(
            id: 'weight_loss',
            name: '체중 감소',
            description: '의도하지 않은 체중 감소',
            categoryId: 'general',
          ),
        ],
      ),
      SymptomCategory(
        id: 'head_face',
        name: '머리 / 얼굴',
        description: '머리와 얼굴 부위의 증상',
        symptoms: [
          Symptom(
            id: 'headache',
            name: '두통',
            description: '머리가 아픈 증상',
            categoryId: 'head_face',
          ),
          Symptom(
            id: 'dizziness',
            name: '어지럼증',
            description: '머리가 어지럽고 불안정한 느낌',
            categoryId: 'head_face',
          ),
          Symptom(
            id: 'eye_problems',
            name: '눈 충혈 / 가려움 / 통증',
            description: '눈의 불편한 증상들',
            categoryId: 'head_face',
          ),
          Symptom(
            id: 'nasal_congestion',
            name: '코막힘 / 콧물',
            description: '코가 막히거나 콧물이 나는 증상',
            categoryId: 'head_face',
          ),
          Symptom(
            id: 'ear_problems',
            name: '귀 통증 / 이명 / 귀막힘',
            description: '귀와 관련된 다양한 증상',
            categoryId: 'head_face',
          ),
        ],
      ),
      SymptomCategory(
        id: 'respiratory',
        name: '호흡기',
        description: '호흡과 관련된 증상',
        symptoms: [
          Symptom(
            id: 'cough',
            name: '기침',
            description: '기침이 나는 증상',
            categoryId: 'respiratory',
          ),
          Symptom(
            id: 'phlegm',
            name: '가래',
            description: '가래가 생기는 증상',
            categoryId: 'respiratory',
          ),
          Symptom(
            id: 'sore_throat',
            name: '인후통 (목이 아픔)',
            description: '목이 아픈 증상',
            categoryId: 'respiratory',
          ),
          Symptom(
            id: 'hoarseness',
            name: '목 쉼 / 음성 변화',
            description: '목소리가 변하는 증상',
            categoryId: 'respiratory',
          ),
          Symptom(
            id: 'shortness_of_breath',
            name: '호흡곤란 / 숨참',
            description: '숨쉬기가 어려운 증상',
            categoryId: 'respiratory',
          ),
          Symptom(
            id: 'nasal_congestion_resp',
            name: '코막힘',
            description: '호흡기 관련 코막힘',
            categoryId: 'respiratory',
          ),
        ],
      ),
      SymptomCategory(
        id: 'digestive',
        name: '소화기',
        description: '소화와 관련된 증상',
        symptoms: [
          Symptom(
            id: 'abdominal_pain',
            name: '복통',
            description: '배가 아픈 증상',
            categoryId: 'digestive',
          ),
          Symptom(
            id: 'nausea',
            name: '메스꺼움 / 구토',
            description: '토할 것 같은 느낌이나 구토',
            categoryId: 'digestive',
          ),
          Symptom(
            id: 'diarrhea',
            name: '설사',
            description: '묽은 변이 나는 증상',
            categoryId: 'digestive',
          ),
          Symptom(
            id: 'constipation',
            name: '변비',
            description: '대변이 나오지 않는 증상',
            categoryId: 'digestive',
          ),
          Symptom(
            id: 'heartburn',
            name: '속 쓰림',
            description: '속이 쓰린 증상',
            categoryId: 'digestive',
          ),
          Symptom(
            id: 'belching',
            name: '트림 / 가스참',
            description: '트림이나 가스가 차는 증상',
            categoryId: 'digestive',
          ),
          Symptom(
            id: 'indigestion',
            name: '소화불량',
            description: '소화가 잘 되지 않는 증상',
            categoryId: 'digestive',
          ),
        ],
      ),
      SymptomCategory(
        id: 'musculoskeletal',
        name: '근골격계',
        description: '근육과 뼈, 관절과 관련된 증상',
        symptoms: [
          Symptom(
            id: 'joint_pain',
            name: '관절통',
            description: '관절이 아픈 증상',
            categoryId: 'musculoskeletal',
          ),
          Symptom(
            id: 'muscle_pain',
            name: '근육통',
            description: '근육이 아픈 증상',
            categoryId: 'musculoskeletal',
          ),
          Symptom(
            id: 'back_pain',
            name: '허리통증 (요통)',
            description: '허리가 아픈 증상',
            categoryId: 'musculoskeletal',
          ),
          Symptom(
            id: 'neck_pain',
            name: '목덜미 통증',
            description: '목덜미가 아픈 증상',
            categoryId: 'musculoskeletal',
          ),
          Symptom(
            id: 'numbness',
            name: '팔/다리 저림',
            description: '팔이나 다리가 저린 증상',
            categoryId: 'musculoskeletal',
          ),
        ],
      ),
      SymptomCategory(
        id: 'skin',
        name: '피부 / 외형',
        description: '피부와 외형과 관련된 증상',
        symptoms: [
          Symptom(
            id: 'rash',
            name: '피부 발진 / 두드러기',
            description: '피부에 붉은 반점이나 두드러기가 생기는 증상',
            categoryId: 'skin',
          ),
          Symptom(
            id: 'itching',
            name: '가려움증',
            description: '피부가 가려운 증상',
            categoryId: 'skin',
          ),
          Symptom(
            id: 'edema',
            name: '부종 (붓기)',
            description: '몸이 붓는 증상',
            categoryId: 'skin',
          ),
          Symptom(
            id: 'bruise',
            name: '멍 / 외상',
            description: '멍이나 외상이 있는 증상',
            categoryId: 'skin',
          ),
        ],
      ),
      SymptomCategory(
        id: 'urological',
        name: '비뇨기 / 생식기',
        description: '비뇨기와 생식기와 관련된 증상',
        symptoms: [
          Symptom(
            id: 'dysuria',
            name: '소변 시 통증 (배뇨통)',
            description: '소변을 볼 때 아픈 증상',
            categoryId: 'urological',
          ),
          Symptom(
            id: 'frequent_urination',
            name: '빈뇨 / 야뇨',
            description: '소변을 자주 보는 증상',
            categoryId: 'urological',
          ),
          Symptom(
            id: 'menstrual_pain',
            name: '생리통 / 생리불순',
            description: '생리와 관련된 통증이나 불규칙함',
            categoryId: 'urological',
          ),
          Symptom(
            id: 'vaginal_discharge',
            name: '질 분비물 증가',
            description: '질 분비물이 늘어나는 증상',
            categoryId: 'urological',
          ),
          Symptom(
            id: 'penile_itching',
            name: '음경 가려움 / 통증',
            description: '음경이 가렵거나 아픈 증상',
            categoryId: 'urological',
          ),
        ],
      ),
      SymptomCategory(
        id: 'neurological',
        name: '신경 / 정신',
        description: '신경계와 정신과 관련된 증상',
        symptoms: [
          Symptom(
            id: 'insomnia',
            name: '불면증',
            description: '잠을 잘 자지 못하는 증상',
            categoryId: 'neurological',
          ),
          Symptom(
            id: 'anxiety',
            name: '불안감 / 초조함',
            description: '불안하고 초조한 느낌',
            categoryId: 'neurological',
          ),
          Symptom(
            id: 'depression',
            name: '우울감',
            description: '우울하고 침울한 느낌',
            categoryId: 'neurological',
          ),
          Symptom(
            id: 'concentration',
            name: '집중력 저하',
            description: '집중하기 어려운 증상',
            categoryId: 'neurological',
          ),
          Symptom(
            id: 'memory',
            name: '기억력 저하',
            description: '기억력이 떨어지는 증상',
            categoryId: 'neurological',
          ),
          Symptom(
            id: 'seizure',
            name: '경련 / 발작',
            description: '경련이나 발작이 일어나는 증상',
            categoryId: 'neurological',
          ),
        ],
      ),
    ];
  }

  static List<Symptom> getAllSymptoms() {
    List<Symptom> allSymptoms = [];
    for (var category in getCategories()) {
      allSymptoms.addAll(category.symptoms);
    }
    return allSymptoms;
  }

  static Symptom? getSymptomById(String id) {
    for (var category in getCategories()) {
      for (var symptom in category.symptoms) {
        if (symptom.id == id) {
          return symptom;
        }
      }
    }
    return null;
  }

  static SymptomCategory? getCategoryById(String id) {
    for (var category in getCategories()) {
      if (category.id == id) {
        return category;
      }
    }
    return null;
  }
}
