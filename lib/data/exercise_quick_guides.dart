/// 每个动作的 3 句大白话极简口诀（每条严格 <= 15 字，扫一眼就能练）
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

/// 58 个核心动作的大白话三句口诀（准备姿势 / 发力动作 / 避坑提醒，每条 <= 15 字）
const Map<String, ExerciseQuickCue> exerciseQuickCueMap = {
  // ==================== 胸部 (14) ====================
  'chest_01': ExerciseQuickCue(
    setup: '沉肩收紧肩胛，双脚踩实地面',
    action: '慢放至胸口中线，呼气推起',
    warning: '别耸肩，手肘别外展成90度',
  ),
  'chest_02': ExerciseQuickCue(
    setup: '调30度上斜凳，挺胸稳住核心',
    action: '哑铃下放锁骨旁，夹胸推起',
    warning: '椅背别太陡，避免练成推肩',
  ),
  'chest_03': ExerciseQuickCue(
    setup: '双脚卡紧护垫，收紧肩胛骨',
    action: '杠铃慢落胸下沿，垂直推起',
    warning: '别用胸口弹杠，控制下放速度',
  ),
  'chest_04': ExerciseQuickCue(
    setup: '30度凳对齐史密斯杆下放线',
    action: '慢放到锁骨下，发力推至微屈',
    warning: '顶端别锁死手肘，别借力耸肩',
  ),
  'chest_05': ExerciseQuickCue(
    setup: '调座椅让把手对齐胸口中线',
    action: '后背贴紧靠垫，向前推并夹胸',
    warning: '推起时别含胸，肩别离开靠背',
  ),
  'chest_06': ExerciseQuickCue(
    setup: '挺胸沉肩，双肘微屈对齐胸口',
    action: '想象环抱大树，向胸前夹紧',
    warning: '别弯手肘变推举，别耸肩代偿',
  ),
  'chest_07': ExerciseQuickCue(
    setup: '滑轮调高，弓步站稳身体微前倾',
    action: '手肘微屈，向小腹前下方夹紧',
    warning: '别甩腰借力，手臂别伸太直',
  ),
  'chest_08': ExerciseQuickCue(
    setup: '滑轮调最低，挺胸微后倾站稳',
    action: '掌心朝上，向胸口上方夹拢',
    warning: '别靠二头硬弯举，保持沉肩',
  ),
  'chest_09': ExerciseQuickCue(
    setup: '仰卧平凳，沉肩微弓背踩稳地',
    action: '哑铃慢落胸两侧，夹胸推起',
    warning: '顶端别撞哑铃，手肘微内收',
  ),
  'chest_10': ExerciseQuickCue(
    setup: '仰卧平凳，双手微屈举在胸前',
    action: '像抱球般向两侧展开再夹拢',
    warning: '下放别过低，手肘角度别乱变',
  ),
  'chest_11': ExerciseQuickCue(
    setup: '30度上斜卧，双手微屈掌相对',
    action: '慢展至上胸拉伸，再向上夹紧',
    warning: '重量别贪大，防止肩前侧拉伤',
  ),
  'chest_12': ExerciseQuickCue(
    setup: '撑住双杠，身体略前倾屈膝',
    action: '慢下至肩低于肘，推起夹下胸',
    warning: '别直上直下，防止肩关节过伸',
  ),
  'chest_13': ExerciseQuickCue(
    setup: '双手略宽于肩，全身绷成直线',
    action: '胸口贴近地面，夹胸用力推起',
    warning: '别塌腰撅屁股，手肘朝后45度',
  ),
  'chest_14': ExerciseQuickCue(
    setup: '上背横靠平凳，双手托住哑铃',
    action: '哑铃慢落头后拉伸，再拉回胸前',
    warning: '腰别过度反弓，保持手肘微屈',
  ),

  // ==================== 背部 (14) ====================
  'back_01': ExerciseQuickCue(
    setup: '宽距正握单杠，先沉肩启动',
    action: '胸口找单杠，手肘向下后拉',
    warning: '别甩腿荡秋千，别用下巴硬够',
  ),
  'back_02': ExerciseQuickCue(
    setup: '与肩同宽反握，收紧核心沉肩',
    action: '手肘贴身下拉，胸口贴近单杠',
    warning: '别圆肩含胸，下放别猛然掉下',
  ),
  'back_03': ExerciseQuickCue(
    setup: '膝盖卡紧护垫，宽握微后仰',
    action: '先沉肩，把横杆拉到锁骨前',
    warning: '别大幅后仰借力，别只用手臂拉',
  ),
  'back_04': ExerciseQuickCue(
    setup: '与肩同宽反握，挺胸坐稳卡腿',
    action: '肘部贴近身体，垂直下拉到胸',
    warning: '别耸肩弯腰，慢放感受背拉伸',
  ),
  'back_05': ExerciseQuickCue(
    setup: '俯身约45度，腰背挺直收核心',
    action: '沿大腿把杠铃拉向肚脐位置',
    warning: '严禁弓背弯腰，别猛甩借力',
  ),
  'back_06': ExerciseQuickCue(
    setup: '反握与肩同宽，俯身约30度',
    action: '手肘贴身向后拉杠到小腹',
    warning: '别直起腰代偿，控制回落节奏',
  ),
  'back_07': ExerciseQuickCue(
    setup: '一手一膝撑凳，背部平直稳住',
    action: '沿弧线把哑铃拉向同侧胯部',
    warning: '别拧腰翻身，别用二头垂直拎',
  ),
  'back_08': ExerciseQuickCue(
    setup: '跨立稳住下盘，挺胸俯身抓把',
    action: '向后夹紧肩胛，拉把手贴胸腹',
    warning: '别含胸驼背，别借惯性乱晃',
  ),
  'back_09': ExerciseQuickCue(
    setup: '双脚踩实踏板，腰背挺直微屈膝',
    action: '沉肩向肚脐拉，用力夹紧背心',
    warning: '别前后大幅摇晃，别耸肩拉',
  ),
  'back_10': ExerciseQuickCue(
    setup: '坐稳或半跪，单手握把挺胸',
    action: '手肘贴腰向后拉，顶峰停1秒',
    warning: '别过度扭转脊柱，保持沉肩',
  ),
  'back_11': ExerciseQuickCue(
    setup: '俯卧30度上斜凳，胸贴靠垫',
    action: '双肘向后上方划船，夹紧上背',
    warning: '胸别离凳借力，哑铃别甩起来',
  ),
  'back_12': ExerciseQuickCue(
    setup: '俯身微屈膝，双臂微弯握高绳',
    action: '直臂划弧下压至大腿前侧',
    warning: '手肘别来回屈伸，别压成三头',
  ),
  'back_13': ExerciseQuickCue(
    setup: '胸口贴紧护垫，调座椅握把手',
    action: '手肘向后下方拉，夹紧肩胛骨',
    warning: '别离开胸垫，别耸肩用斜方拉',
  ),
  'back_14': ExerciseQuickCue(
    setup: '护垫卡在大腿根，脚跟踩稳',
    action: '屈髋俯身，夹臀挺起至成直线',
    warning: '别过度反弓腰椎，起身别太猛',
  ),

  // ==================== 肩部 (14) ====================
  'shoulder_01': ExerciseQuickCue(
    setup: '靠背近垂直，握距略宽于肩',
    action: '从下巴前垂直推至头顶上方',
    warning: '腰别离凳反弓，手腕别向后折',
  ),
  'shoulder_02': ExerciseQuickCue(
    setup: '站稳收腹夹臀，杠铃置锁骨前',
    action: '微仰头让路，垂直向上推过头',
    warning: '别借膝盖弹起，别向后顶腰',
  ),
  'shoulder_03': ExerciseQuickCue(
    setup: '坐稳贴靠背，哑铃举至耳旁',
    action: '手肘略向前收，弧线推至头顶',
    warning: '顶端别碰哑铃，别耸肩顶脖',
  ),
  'shoulder_04': ExerciseQuickCue(
    setup: '坐姿挺胸，掌心朝脸持铃胸前',
    action: '外展旋转手腕并顺势向上推起',
    warning: '旋转要丝滑，重量别选太大',
  ),
  'shoulder_05': ExerciseQuickCue(
    setup: '调座椅让把手与耳朵齐平',
    action: '后背贴紧靠背，向上推至微屈',
    warning: '别耸肩发力，顶端别锁死手肘',
  ),
  'shoulder_06': ExerciseQuickCue(
    setup: '站姿微前倾，双手微屈持哑铃',
    action: '手肘带动向侧上方抬至肩平',
    warning: '别耸肩甩腰，手别抬高过肩膀',
  ),
  'shoulder_07': ExerciseQuickCue(
    setup: '坐凳边缘挺胸，消除下肢借力',
    action: '肘部领跑，平稳抬至与肩同高',
    warning: '下放别砸腿，重量宁轻勿重',
  ),
  'shoulder_08': ExerciseQuickCue(
    setup: '一手抓架身体微斜，稳定核心',
    action: '另一手微屈向上平举至肩平',
    warning: '别借身体回弹，全程匀速控制',
  ),
  'shoulder_09': ExerciseQuickCue(
    setup: '低位滑轮置身侧，坐稳挺胸',
    action: '单手拉绳向斜外侧抬至肩平',
    warning: '别歪腰代偿，拉绳别挂蹭膝盖',
  ),
  'shoulder_10': ExerciseQuickCue(
    setup: '绳索调至额头高，双手对握',
    action: '向眉心方向拉，同时外展双拳',
    warning: '手肘别掉下来，别靠身体后倒',
  ),
  'shoulder_11': ExerciseQuickCue(
    setup: '俯身接近平行，腰背挺直稳住',
    action: '双臂微屈向两侧后上方展开',
    warning: '别直腰甩哑铃，别刻意猛夹背',
  ),
  'shoulder_12': ExerciseQuickCue(
    setup: '面对靠垫坐稳，掌心相对握把',
    action: '保持手肘微屈，向后平展夹后肩',
    warning: '别耸肩缩脖，别过度后仰借力',
  ),
  'shoulder_13': ExerciseQuickCue(
    setup: '站姿收紧核心，哑铃置大腿前',
    action: '双臂微屈交替前举至与眼齐平',
    warning: '别向后仰腰甩铃，慢放控节奏',
  ),
  'shoulder_14': ExerciseQuickCue(
    setup: '双手抓杠铃片两侧，站稳收腹',
    action: '前平举至眼前，可轻微左右转',
    warning: '别耸肩弯腰，重量别选过重',
  ),

  // ==================== 手臂 (16) ====================
  'arms_01': ExerciseQuickCue(
    setup: '站稳收核心，手肘夹紧身体两侧',
    action: '大臂不动，弯举杠铃至胸前挤压',
    warning: '别晃腰借力，手肘别向前乱跑',
  ),
  'arms_02': ExerciseQuickCue(
    setup: '顺势握曲杆，挺胸收腹夹双肘',
    action: '平稳弯举至顶峰停1秒再慢放',
    warning: '别甩背起身，下放别完全松掉',
  ),
  'arms_03': ExerciseQuickCue(
    setup: '自然垂臂持哑铃，站稳夹双肘',
    action: '交替弯举并外旋小指朝向肩膀',
    warning: '别左右歪身借力，大臂别乱晃',
  ),
  'arms_04': ExerciseQuickCue(
    setup: '躺45度上斜凳，双臂自然垂后',
    action: '大臂稳在身侧后，弯举哑铃',
    warning: '别把肘往前顶，下放要充分拉长',
  ),
  'arms_05': ExerciseQuickCue(
    setup: '腋下贴紧斜托垫，双臂放稳',
    action: '专注二头收缩，平稳向上弯举',
    warning: '底端别猛然伸直，防拉伤肌腱',
  ),
  'arms_06': ExerciseQuickCue(
    setup: '坐姿俯身，单肘顶在大腿内侧',
    action: '孤立弯举哑铃至肩前，挤压1秒',
    warning: '别靠大腿往上顶，慢放控张力',
  ),
  'arms_07': ExerciseQuickCue(
    setup: '掌心相对对握哑铃，双肘贴身',
    action: '像抡锤子般向上弯举至胸前',
    warning: '别甩肩晃身，下放保持张力',
  ),
  'arms_08': ExerciseQuickCue(
    setup: '低滑轮配牧师凳，大臂贴稳垫',
    action: '顶住恒定阻力，平稳向上弯举',
    warning: '别借后仰拉绳，顶峰多停半秒',
  ),
  'arms_09': ExerciseQuickCue(
    setup: '高滑轮握直杆，大臂贴紧肋骨',
    action: '固定上臂，前臂向下压至伸直',
    warning: '别靠体重往下压，手肘别前后晃',
  ),
  'arms_10': ExerciseQuickCue(
    setup: '抓紧绳把微前倾，双肘夹紧身侧',
    action: '向下压到底并将绳把向两侧分开',
    warning: '回放别超胸口太高，大臂别乱动',
  ),
  'arms_11': ExerciseQuickCue(
    setup: '仰卧平凳，曲杆举至额头正上方',
    action: '大臂微后倾不动，屈肘下放再推',
    warning: '手肘别向外撇，控制下放防砸头',
  ),
  'arms_12': ExerciseQuickCue(
    setup: '坐稳双手托哑铃举过头顶',
    action: '夹紧双肘，慢落脑后再向上伸直',
    warning: '别过度顶腰，手肘别往两侧张开',
  ),
  'arms_13': ExerciseQuickCue(
    setup: '背对龙门架微前倾，双手头后握绳',
    action: '固定大臂，向前上方伸直双臂',
    warning: '别靠腰腹猛拉，感受三头长头拉伸',
  ),
  'arms_14': ExerciseQuickCue(
    setup: '背靠平凳双手撑边，腿伸向前',
    action: '臀贴凳缘慢下，推起挤压三头',
    warning: '别下太深伤肩，身体别离凳太远',
  ),
  'arms_15': ExerciseQuickCue(
    setup: '仰卧窄距握杠（约与肩同宽）',
    action: '手肘夹紧身体，慢落胸下沿推起',
    warning: '握距别太窄伤腕，手肘别外翻',
  ),
  'arms_16': ExerciseQuickCue(
    setup: '前臂稳靠凳面，掌心朝上握低绳',
    action: '仅靠手腕向上卷曲拉动绳索',
    warning: '前臂别抬离凳面，动作别太快',
  ),
};

/// 一键平替映射：器械被占/没有该器械时，优先推荐 1~2 个同肌群的【哑铃】或【徒手】动作
const Map<String, List<String>> equipmentSwapMap = {
  // 胸部平替
  'chest_01': ['chest_09', 'chest_13'], // 平板杠铃卧推 -> 平板哑铃卧推 / 标准俯卧撑
  'chest_02': ['chest_11', 'chest_13'], // 上斜哑铃卧推 -> 上斜哑铃飞鸟 / 标准俯卧撑
  'chest_03': ['chest_12', 'chest_09'], // 下斜杠铃卧推 -> 双杠臂屈伸 / 平板哑铃卧推
  'chest_04': ['chest_02', 'chest_11'], // 史密斯上斜推胸 -> 上斜哑铃卧推 / 上斜哑铃飞鸟
  'chest_05': ['chest_09', 'chest_13'], // 坐姿器械推胸 -> 平板哑铃卧推 / 标准俯卧撑
  'chest_06': ['chest_10', 'chest_13'], // 蝴蝶机夹胸 -> 平板哑铃飞鸟 / 标准俯卧撑
  'chest_07': ['chest_12', 'chest_10'], // 龙门架高位夹胸 -> 双杠臂屈伸 / 平板哑铃飞鸟
  'chest_08': ['chest_11', 'chest_02'], // 龙门架低位夹胸 -> 上斜哑铃飞鸟 / 上斜哑铃卧推
  'chest_09': ['chest_13', 'chest_10'], // 平板哑铃卧推 -> 标准俯卧撑 / 平板哑铃飞鸟
  'chest_10': ['chest_13', 'chest_09'], // 平板哑铃飞鸟 -> 标准俯卧撑 / 平板哑铃卧推
  'chest_11': ['chest_02', 'chest_13'], // 上斜哑铃飞鸟 -> 上斜哑铃卧推 / 标准俯卧撑
  'chest_14': ['chest_10', 'chest_13'], // 哑铃仰卧拉举 -> 平板哑铃飞鸟 / 标准俯卧撑

  // 背部平替
  'back_03': ['back_01', 'back_07'], // 宽距高位下拉 -> 宽距正手引体向上 / 单臂哑铃划船
  'back_04': ['back_02', 'back_07'], // 窄距反手高位下拉 -> 反手引体向上 / 单臂哑铃划船
  'back_05': ['back_07', 'back_11'], // 俯身杠铃划船 -> 单臂哑铃划船 / 上斜哑铃划船
  'back_06': ['back_07', 'back_02'], // 反握俯身杠铃划船 -> 单臂哑铃划船 / 反手引体向上
  'back_07': ['back_11', 'back_01'], // 单臂哑铃划船 -> 上斜哑铃划船 / 宽距正手引体向上
  'back_08': ['back_11', 'back_07'], // T杠划船 -> 上斜哑铃划船 / 单臂哑铃划船
  'back_09': ['back_07', 'back_11'], // 坐姿绳索划船 -> 单臂哑铃划船 / 上斜哑铃划船
  'back_10': ['back_07', 'back_11'], // 单臂绳索划船 -> 单臂哑铃划船 / 上斜哑铃划船
  'back_11': ['back_07', 'back_01'], // 上斜哑铃划船 -> 单臂哑铃划船 / 宽距正手引体向上
  'back_12': ['back_07', 'back_01'], // 直臂绳索下压 -> 单臂哑铃划船 / 宽距正手引体向上
  'back_13': ['back_11', 'back_01'], // 器械高位划船 -> 上斜哑铃划船 / 宽距正手引体向上
  'back_14': ['back_07', 'back_11'], // 罗马椅挺身 -> 单臂哑铃划船 / 上斜哑铃划船

  // 肩部平替
  'shoulder_01': ['shoulder_03', 'shoulder_04'], // 坐姿杠铃推举 -> 坐姿哑铃推举 / 阿诺德推举
  'shoulder_02': ['shoulder_03', 'shoulder_04'], // 站姿杠铃推举 -> 坐姿哑铃推举 / 阿诺德推举
  'shoulder_03': ['shoulder_04', 'shoulder_13'], // 坐姿哑铃推举 -> 阿诺德推举 / 哑铃前平举
  'shoulder_04': ['shoulder_03', 'shoulder_06'], // 阿诺德推举 -> 坐姿哑铃推举 / 站姿哑铃侧平举
  'shoulder_05': ['shoulder_03', 'shoulder_04'], // 固定器械推肩 -> 坐姿哑铃推举 / 阿诺德推举
  'shoulder_06': ['shoulder_07', 'shoulder_08'], // 站姿哑铃侧平举 -> 坐姿哑铃侧平举 / 单臂哑铃侧平举
  'shoulder_07': ['shoulder_06', 'shoulder_08'], // 坐姿哑铃侧平举 -> 站姿哑铃侧平举 / 单臂哑铃侧平举
  'shoulder_08': ['shoulder_06', 'shoulder_07'], // 单臂哑铃侧平举 -> 站姿哑铃侧平举 / 坐姿哑铃侧平举
  'shoulder_09': ['shoulder_06', 'shoulder_07'], // 坐姿绳索侧平举 -> 站姿哑铃侧平举 / 坐姿哑铃侧平举
  'shoulder_10': ['shoulder_11', 'shoulder_07'], // 绳索面拉 -> 俯身哑铃反向飞鸟 / 坐姿哑铃侧平举
  'shoulder_11': ['shoulder_07', 'shoulder_06'], // 俯身哑铃反向飞鸟 -> 坐姿哑铃侧平举 / 站姿哑铃侧平举
  'shoulder_12': ['shoulder_11', 'shoulder_07'], // 蝴蝶机反向飞鸟 -> 俯身哑铃反向飞鸟 / 坐姿哑铃侧平举
  'shoulder_13': ['shoulder_03', 'shoulder_04'], // 哑铃前平举 -> 坐姿哑铃推举 / 阿诺德推举
  'shoulder_14': ['shoulder_13', 'shoulder_03'], // 杠铃片前平举 -> 哑铃前平举 / 坐姿哑铃推举

  // 手臂平替
  'arms_01': ['arms_03', 'arms_07'], // 站姿直杆杠铃弯举 -> 哑铃交替弯举 / 哑铃锤式弯举
  'arms_02': ['arms_03', 'arms_07'], // 站姿EZ曲杆弯举 -> 哑铃交替弯举 / 哑铃锤式弯举
  'arms_03': ['arms_07', 'arms_06'], // 哑铃交替弯举 -> 哑铃锤式弯举 / 坐姿集中弯举
  'arms_04': ['arms_03', 'arms_06'], // 上斜哑铃弯举 -> 哑铃交替弯举 / 坐姿集中弯举
  'arms_05': ['arms_06', 'arms_03'], // 牧师凳杠铃弯举 -> 坐姿集中弯举 / 哑铃交替弯举
  'arms_06': ['arms_03', 'arms_07'], // 坐姿集中弯举 -> 哑铃交替弯举 / 哑铃锤式弯举
  'arms_07': ['arms_03', 'arms_06'], // 哑铃锤式弯举 -> 哑铃交替弯举 / 坐姿集中弯举
  'arms_08': ['arms_06', 'arms_03'], // 绳索牧师凳弯举 -> 坐姿集中弯举 / 哑铃交替弯举
  'arms_09': ['arms_12', 'arms_14'], // 直杆绳索下压 -> 哑铃双臂颈后臂屈伸 / 板凳臂屈伸
  'arms_10': ['arms_12', 'arms_14'], // 龙门架绳索下压 -> 哑铃双臂颈后臂屈伸 / 板凳臂屈伸
  'arms_11': ['arms_12', 'arms_14'], // 仰卧EZ杆臂屈伸 -> 哑铃双臂颈后臂屈伸 / 板凳臂屈伸
  'arms_12': ['arms_14', 'chest_12'], // 哑铃双臂颈后臂屈伸 -> 板凳臂屈伸 / 双杠臂屈伸
  'arms_13': ['arms_12', 'arms_14'], // 绳索过顶臂屈伸 -> 哑铃双臂颈后臂屈伸 / 板凳臂屈伸
  'arms_15': ['arms_14', 'arms_12'], // 窄距杠铃卧推 -> 板凳臂屈伸 / 哑铃双臂颈后臂屈伸
  'arms_16': ['arms_07', 'arms_03'], // 绳索手腕屈伸 -> 哑铃锤式弯举 / 哑铃交替弯举
};
