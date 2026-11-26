/// 每个动作的 3 句大白话极简口诀（扫一眼就能练，精准对应 69 个黄金动作）
class ExerciseQuickCue {
  final String setup; // 准备姿势
  final String action; // 发力动作
  final String warning; // 避坑提醒

  const ExerciseQuickCue({
    required this.setup,
    required this.action,
    required this.warning,
  });
}

/// 69 个精选黄金动作的大白话三句口诀（准备姿势 / 发力动作 / 避坑提醒）
const Map<String, ExerciseQuickCue> exerciseQuickCueMap = {
  // ==================== 胸部 (12) ====================
  'chest_01': ExerciseQuickCue(
    setup: '沉肩收紧肩胛，双脚踩实地面',
    action: '慢放至胸口下沿，呼气弧线推起',
    warning: '别耸肩，手肘别外展成 90 度',
  ),
  'chest_02': ExerciseQuickCue(
    setup: '卧推凳调 30° 上斜，沉肩锁背',
    action: '杠铃慢落锁骨下，上胸推起',
    warning: '凳角别超 45°，防练成推肩',
  ),
  'chest_03': ExerciseQuickCue(
    setup: '双脚卡紧护垫，肩胛贴紧凳面',
    action: '慢放至下胸边缘，垂直推起',
    warning: '严禁胸口弹杠，控速 3 秒下放',
  ),
  'chest_04': ExerciseQuickCue(
    setup: '仰卧平凳沉肩，哑铃微呈内八',
    action: '慢放胸两侧，夹胸弧线推起',
    warning: '顶端留一拳距，别用力撞哑铃',
  ),
  'chest_05': ExerciseQuickCue(
    setup: '调 30° 上斜凳，挺胸核心踩稳',
    action: '哑铃落锁骨旁，夹紧上胸推起',
    warning: '椅背别太陡，肩别离开靠背',
  ),
  'chest_06': ExerciseQuickCue(
    setup: '仰卧平凳，双手掌相对微屈肘',
    action: '像抱大树向两侧展再胸前夹拢',
    warning: '肘角别乱变，下放别低于肩平',
  ),
  'chest_07': ExerciseQuickCue(
    setup: '30° 上斜卧，沉肩双肘固定微屈',
    action: '向两侧慢展拉伸，再向上夹紧',
    warning: '重量别贪大，保护肩前侧韧带',
  ),
  'chest_08': ExerciseQuickCue(
    setup: '滑轮调高，弓步站稳微前倾',
    action: '手肘微屈，向小腹前下方夹紧',
    warning: '别甩腰借力，回放别拉过肩后',
  ),
  'chest_09': ExerciseQuickCue(
    setup: '滑轮与肩齐平，分腿挺胸站稳',
    action: '双臂微屈水平向胸口前方合拢',
    warning: '别含胸驼背，别屈伸肘变推胸',
  ),
  'chest_10': ExerciseQuickCue(
    setup: '滑轮调最低，掌心朝前挺胸站',
    action: '沿斜上方弧线向锁骨前夹拢',
    warning: '别用二头硬弯举，保持沉肩',
  ),
  'chest_11': ExerciseQuickCue(
    setup: '撑住双杠，身体前倾 30° 屈膝',
    action: '慢下至大臂略低于肘再撑起',
    warning: '别直上直下，下沉时别耸肩',
  ),
  'chest_12': ExerciseQuickCue(
    setup: '双手略宽于肩，全身绷成直线',
    action: '胸口贴近地面，夹胸发力推起',
    warning: '别塌腰撅屁股，手肘朝后 45°',
  ),

  // ==================== 背部 (12) ====================
  'back_01': ExerciseQuickCue(
    setup: '宽距正握单杠，先沉肩启动',
    action: '胸口主动找杠，手肘向下内收',
    warning: '别甩腿荡秋千，别用下巴硬够',
  ),
  'back_02': ExerciseQuickCue(
    setup: '与肩同宽反握，挺胸收腹沉肩',
    action: '手肘贴身下拉，上胸贴近单杠',
    warning: '别圆肩含胸，下放别自由坠落',
  ),
  'back_03': ExerciseQuickCue(
    setup: '膝盖卡紧护垫，宽握微后倾',
    action: '先沉肩，双肘垂直下拉至锁骨',
    warning: '别大幅后仰借力，别只用手拉',
  ),
  'back_04': ExerciseQuickCue(
    setup: '与肩同宽反握，挺胸坐稳卡腿',
    action: '双肘贴紧肋骨，垂直拉到上胸',
    warning: '底端别耸肩内扣，慢放拉长背',
  ),
  'back_05': ExerciseQuickCue(
    setup: '双手对握 V 把，挺胸微仰卡稳',
    action: '双肘贴身向胸下沿垂直拉下',
    warning: '别前后摇晃，手肘别向外翻开',
  ),
  'back_06': ExerciseQuickCue(
    setup: '俯身 45°，腰背绷直收紧核心',
    action: '杠铃贴大腿向肚脐下腹拉起',
    warning: '严禁弓背弯腰，别猛挺腰甩杠',
  ),
  'back_07': ExerciseQuickCue(
    setup: '反握与肩同宽，俯身约 30°',
    action: '手肘贴身沿腿向小腹后上方拉',
    warning: '别用二头弯举，保持俯身角度',
  ),
  'back_08': ExerciseQuickCue(
    setup: '一手一膝撑稳凳，背部绷水平',
    action: '沿弧线把哑铃拉向同侧胯部',
    warning: '别拧腰翻身，别垂直往上硬拎',
  ),
  'back_09': ExerciseQuickCue(
    setup: '俯卧 30° 上斜凳，胸贴紧靠垫',
    action: '双肘向后上方划船夹紧上背',
    warning: '胸别离凳借力，哑铃别猛甩起',
  ),
  'back_10': ExerciseQuickCue(
    setup: '双脚踩实微屈膝，腰背挺直',
    action: '沉肩向肚脐水平拉，夹紧背心',
    warning: '别像划龙舟前后摇，别耸肩拉',
  ),
  'back_11': ExerciseQuickCue(
    setup: '俯身微屈膝，双臂微弯握高杆',
    action: '直臂划大弧下压至大腿前侧',
    warning: '手肘别来回屈伸，别压成三头',
  ),
  'back_12': ExerciseQuickCue(
    setup: '护垫卡在大腿根，脚跟踩实',
    action: '屈髋俯身，夹臀挺起成直线',
    warning: '顶部别过度反弓腰，起身控速',
  ),

  // ==================== 肩部 (11) ====================
  'shoulder_01': ExerciseQuickCue(
    setup: '靠背调 80°，握距略宽置锁骨',
    action: '收腹垂直向上推过头顶不锁肘',
    warning: '腰别离凳反弓，手腕别向后折',
  ),
  'shoulder_02': ExerciseQuickCue(
    setup: '站稳收腹夹臀，杠铃置锁骨前',
    action: '微仰头让路，垂直推至耳上方',
    warning: '别借膝盖弹起，别顶肚子仰腰',
  ),
  'shoulder_03': ExerciseQuickCue(
    setup: '坐稳贴靠背，哑铃举至双耳旁',
    action: '大臂微前收，弧线推至头顶',
    warning: '顶端别磕哑铃，别耸肩缩脖子',
  ),
  'shoulder_04': ExerciseQuickCue(
    setup: '坐姿挺胸，掌心朝脸持铃胸前',
    action: '外展旋转手腕顺势丝滑推起',
    warning: '重量选轻一档，旋转别卡顿',
  ),
  'shoulder_05': ExerciseQuickCue(
    setup: '站姿微前倾，双手微屈持哑铃',
    action: '沉肩手肘领跑向侧上方抬至肩平',
    warning: '别耸肩甩腰，手别抬高过肩膀',
  ),
  'shoulder_06': ExerciseQuickCue(
    setup: '坐凳边缘挺胸，消除下肢借力',
    action: '肘部领跑平稳抬至与肩同高',
    warning: '底部别砸腿反弹，宁轻勿重',
  ),
  'shoulder_07': ExerciseQuickCue(
    setup: '滑轮调腕高，一手扶架稳核心',
    action: '单手微屈向斜外侧拉升至肩平',
    warning: '别歪腰侧倾甩绳，全程匀速控',
  ),
  'shoulder_08': ExerciseQuickCue(
    setup: '绳索调额头高，拇指朝后对握',
    action: '拉向眉心同时双拳外旋展示二头',
    warning: '手肘别掉下去，别靠身体后倒',
  ),
  'shoulder_09': ExerciseQuickCue(
    setup: '俯身近水平或靠斜凳，背挺直',
    action: '双臂微屈向两侧斜后方展开',
    warning: '别刻意猛夹背，别直腰甩哑铃',
  ),
  'shoulder_10': ExerciseQuickCue(
    setup: '站稳收核心，哑铃轻置大腿前',
    action: '双臂微屈平稳前平举至眼齐平',
    warning: '别仰腰甩铃，沉肩远离耳朵',
  ),
  'shoulder_11': ExerciseQuickCue(
    setup: '双手垂持哑铃，挺胸目视前方',
    action: '双肩笔直向双耳用力上提停 1 秒',
    warning: '严禁转圈绕肩，别低头探脖子',
  ),

  // ==================== 手臂 (14) ====================
  'arms_01': ExerciseQuickCue(
    setup: '站稳收核心，双肘夹紧体侧',
    action: '大臂不动，弯举杠铃至胸前挤压',
    warning: '别晃腰借力，手肘别往前乱跑',
  ),
  'arms_02': ExerciseQuickCue(
    setup: '顺势握曲杆弯角，挺胸夹双肘',
    action: '平稳弯举至顶峰停 1 秒再慢放',
    warning: '别勾腕借力，下放别砸到大腿',
  ),
  'arms_03': ExerciseQuickCue(
    setup: '自然垂臂持哑铃，站稳夹双肘',
    action: '交替弯举并外旋小指拧向肩',
    warning: '别左右歪身借力，大臂稳不动',
  ),
  'arms_04': ExerciseQuickCue(
    setup: '躺 45° 上斜凳，双臂自然垂后',
    action: '手肘钉在身侧后方，弧线弯举',
    warning: '肘别往前顶，底端要充分拉长',
  ),
  'arms_05': ExerciseQuickCue(
    setup: '腋下压实斜托垫，双臂稳放',
    action: '零借力孤立向上弯举挤压二头',
    warning: '底端留微屈严禁砸底防拉伤',
  ),
  'arms_06': ExerciseQuickCue(
    setup: '坐稳俯身，大臂顶住大腿内侧',
    action: '孤立弯举至肩前停 1 秒挤肌峰',
    warning: '别靠大腿往上顶，慢放控张力',
  ),
  'arms_07': ExerciseQuickCue(
    setup: '掌心相对对握哑铃，双肘贴身',
    action: '大拇指朝上如抡锤平稳弯举',
    warning: '别甩肩晃身，手腕保持笔直',
  ),
  'arms_08': ExerciseQuickCue(
    setup: '高滑轮握直杆，大臂紧夹肋骨',
    action: '固定上臂，仅伸前臂下压伸直',
    warning: '别压体重硬按，手肘别前后晃',
  ),
  'arms_09': ExerciseQuickCue(
    setup: '对握绳把微前倾，双肘夹腰侧',
    action: '压到底把绳把向两侧用力撕开',
    warning: '回放别太高，大臂全程锁死',
  ),
  'arms_10': ExerciseQuickCue(
    setup: '仰卧平凳窄握杠，大臂微后倾',
    action: '固定大臂屈肘落头后，发力伸直',
    warning: '手肘别往两侧撇，控速防砸头',
  ),
  'arms_11': ExerciseQuickCue(
    setup: '坐稳收腹，双手托哑铃举过头',
    action: '夹紧双肘慢落脑后，发力伸直',
    warning: '别顶腰反弓，双肘别大幅外张',
  ),
  'arms_12': ExerciseQuickCue(
    setup: '背对龙门架弓步前倾，头后握绳',
    action: '固定大臂向前上方伸直展绳把',
    warning: '别甩腰腹，后放深拉伸三头长头',
  ),
  'arms_13': ExerciseQuickCue(
    setup: '仰卧平凳，与肩同宽窄距握杠',
    action: '双肘贴紧身体慢落下胸再推起',
    warning: '别握太窄伤手腕，肘别向外翻',
  ),
  'arms_14': ExerciseQuickCue(
    setup: '背靠平凳双手撑缘，臀贴凳边',
    action: '慢下至大臂平行地面再撑起',
    warning: '别下太深伤肩，身体别离凳远',
  ),

  // ==================== 腿臀 (12) ====================
  'legs_01': ExerciseQuickCue(
    setup: '杠压斜方肌，站略宽脚尖外展',
    action: '吸气慢蹲平行地，全脚掌蹬起',
    warning: '膝盖严禁内扣，腰背严禁弓起',
  ),
  'legs_02': ExerciseQuickCue(
    setup: '杠架三角肌前束，高抬双肘平地',
    action: '保持上身直立垂直深蹲再蹬起',
    warning: '手肘别下垂掉杠，上身别前趴',
  ),
  'legs_03': ExerciseQuickCue(
    setup: '双手托哑铃贴紧胸前，站略宽',
    action: '慢蹲至肘近膝内侧，蹬地起身',
    warning: '哑铃别离胸太远，别踮脚跟',
  ),
  'legs_04': ExerciseQuickCue(
    setup: '杠贴小腿中段，沉肩绷直腰背',
    action: '蹬地同时顶髋，贴腿直线拉起',
    warning: '严禁弓背拉重，顶端别后仰腰',
  ),
  'legs_05': ExerciseQuickCue(
    setup: '微屈膝锁死，挺胸杠铃贴大腿',
    action: '推臀向后慢放膝下，夹臀站起',
    warning: '别弯腰凑触地，别屈膝变深蹲',
  ),
  'legs_06': ExerciseQuickCue(
    setup: '哑铃紧贴大腿前，微屈膝挺背',
    action: '屈髋推臀下放膝下，顶髋起身',
    warning: '哑铃别远离身体，别仰头折颈',
  ),
  'legs_07': ExerciseQuickCue(
    setup: '持铃挺胸迈大步，双脚同髋宽',
    action: '垂直下沉双膝 90°，前脚蹬起',
    warning: '别走成一条线，后膝别砸地面',
  ),
  'legs_08': ExerciseQuickCue(
    setup: '后脚背搭平凳，前脚前移微倾',
    action: '垂直下蹲至平行，前腿主蹬起',
    warning: '后腿别硬蹬凳，前膝别内扣晃',
  ),
  'legs_09': ExerciseQuickCue(
    setup: '肩胛下沿靠凳，杠铃置髋折痕',
    action: '脚跟蹬地猛顶髋，停 2 秒夹臀',
    warning: '收下巴别仰腰，顶峰小腿垂直',
  ),
  'legs_10': ExerciseQuickCue(
    setup: '双手体侧垂持哑铃，挺胸站稳',
    action: '屈髋慢蹲至大腿平地，蹬地起',
    warning: '别含胸驼背，脚跟全程踩实',
  ),
  'legs_11': ExerciseQuickCue(
    setup: '前脚掌踩垫片，杠稳置上背',
    action: '发力踮至最高停 2 秒，慢沉跟',
    warning: '严禁弹簧式快抖，脚踝别外翻',
  ),
  'legs_12': ExerciseQuickCue(
    setup: '坐稳哑铃压膝上，前脚掌垫高',
    action: '小腿顶起脚跟停 2 秒，全幅下放',
    warning: '行程要做满，别用手帮抬哑铃',
  ),

  // ==================== 核心 (8) ====================
  'core_01': ExerciseQuickCue(
    setup: '仰卧屈膝踩地，下背死贴地面',
    action: '吐气卷起肩胛骨，肋骨找骨盆',
    warning: '双手别抱头扯颈，下腰别离地',
  ),
  'core_02': ExerciseQuickCue(
    setup: '抓稳单杠沉肩悬垂，核心锁紧',
    action: '主动向上卷骨盆带起双腿停 1 秒',
    warning: '严禁前后荡秋千，只抬腿练不到',
  ),
  'core_03': ExerciseQuickCue(
    setup: '跪垫手握绳把贴耳，臀部锁死',
    action: '弓背卷腹让手肘找大腿根吐气',
    warning: '别直腰磕头，别用手臂硬拽绳',
  ),
  'core_04': ExerciseQuickCue(
    setup: '坐姿挺胸后仰 45°，核心绷紧',
    action: '胸廓带双肩左右控速扭转挤腹',
    warning: '别含胸只甩手，速度别太快',
  ),
  'core_05': ExerciseQuickCue(
    setup: '跪垫含胸微弓背，锁死骨盆后倾',
    action: '慢推至可控最远点，收腹拉回',
    warning: '严禁塌腰顶肚子，臀别坐脚跟',
  ),
  'core_06': ExerciseQuickCue(
    setup: '仰卧屈髋膝 90°，下腰压实地面',
    action: '对侧手脚慢伸贴地，呼气收回',
    warning: '下腰严禁拱起留缝，别同边顺拐',
  ),
  'core_07': ExerciseQuickCue(
    setup: '仰卧下背压地，手轻扶耳抬双腿',
    action: '慢速转体用肩找对侧膝交替蹬',
    warning: '别疯狂快蹬掰脖子，下腰别拱',
  ),
  'core_08': ExerciseQuickCue(
    setup: '仰卧平凳抓凳缘，下背紧贴凳面',
    action: '下腹抬腿微卷尾骨，控速 3 秒放',
    warning: '腰快离凳就止步，别甩腿借力',
  ),
};

/// 一键平替映射（全部精准指向 69 个动作库内的同肌群哑铃/徒手动作）
const Map<String, List<String>> equipmentSwapMap = {
  // 胸部
  'chest_01': ['chest_04', 'chest_12'],
  'chest_02': ['chest_05', 'chest_07'],
  'chest_03': ['chest_11', 'chest_04'],
  'chest_04': ['chest_12', 'chest_06'],
  'chest_05': ['chest_07', 'chest_12'],
  'chest_06': ['chest_12', 'chest_04'],
  'chest_07': ['chest_05', 'chest_12'],
  'chest_08': ['chest_11', 'chest_06'],
  'chest_09': ['chest_06', 'chest_12'],
  'chest_10': ['chest_07', 'chest_05'],

  // 背部
  'back_03': ['back_01', 'back_08'],
  'back_04': ['back_02', 'back_08'],
  'back_05': ['back_02', 'back_08'],
  'back_06': ['back_08', 'back_09'],
  'back_07': ['back_08', 'back_02'],
  'back_08': ['back_09', 'back_01'],
  'back_09': ['back_08', 'back_01'],
  'back_10': ['back_08', 'back_09'],
  'back_11': ['back_08', 'back_01'],

  // 肩部
  'shoulder_01': ['shoulder_03', 'shoulder_04'],
  'shoulder_02': ['shoulder_03', 'shoulder_04'],
  'shoulder_03': ['shoulder_04', 'shoulder_10'],
  'shoulder_04': ['shoulder_03', 'shoulder_05'],
  'shoulder_05': ['shoulder_06', 'shoulder_04'],
  'shoulder_06': ['shoulder_05', 'shoulder_04'],
  'shoulder_07': ['shoulder_05', 'shoulder_06'],
  'shoulder_08': ['shoulder_09', 'shoulder_06'],
  'shoulder_09': ['shoulder_06', 'shoulder_05'],
  'shoulder_10': ['shoulder_03', 'shoulder_04'],
  'shoulder_11': ['shoulder_09', 'shoulder_05'],

  // 手臂
  'arms_01': ['arms_03', 'arms_07'],
  'arms_02': ['arms_03', 'arms_07'],
  'arms_03': ['arms_07', 'arms_06'],
  'arms_04': ['arms_03', 'arms_06'],
  'arms_05': ['arms_06', 'arms_03'],
  'arms_06': ['arms_03', 'arms_07'],
  'arms_07': ['arms_03', 'arms_06'],
  'arms_08': ['arms_11', 'arms_14'],
  'arms_09': ['arms_11', 'arms_14'],
  'arms_10': ['arms_11', 'arms_14'],
  'arms_11': ['arms_14', 'chest_11'],
  'arms_12': ['arms_11', 'arms_14'],
  'arms_13': ['arms_14', 'arms_11'],

  // 腿臀
  'legs_01': ['legs_03', 'legs_10'],
  'legs_02': ['legs_03', 'legs_08'],
  'legs_03': ['legs_10', 'legs_07'],
  'legs_04': ['legs_06', 'legs_03'],
  'legs_05': ['legs_06', 'legs_08'],
  'legs_06': ['legs_08', 'legs_07'],
  'legs_07': ['legs_08', 'legs_10'],
  'legs_08': ['legs_07', 'legs_03'],
  'legs_09': ['legs_06', 'legs_08'],
  'legs_10': ['legs_03', 'legs_07'],
  'legs_11': ['legs_12', 'legs_10'],
  'legs_12': ['legs_10', 'legs_07'],

  // 核心
  'core_03': ['core_01', 'core_05'],
};
