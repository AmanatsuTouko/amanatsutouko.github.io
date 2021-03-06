//モード切替用関数
int mode = 0;

//mode0 初期画面（タイトル表示）click to start
//mode1 〇×〇を選択 6×6 or 8×8 or 10×10
//      白プレイヤ―の技を2つ表示
//      黒プレイヤ―の技を2つ表示
//mode2 メイン実行画面
//mode3 リザルト表示 click to restart

//skillの数
int skillNumber = 5;

//skill保存用関数
int whiteskill1 = 0;
int whiteskill2 = 0;
int blackskill1 = 0;
int blackskill2 = 0;

//〇×〇マスの碁盤を作る(偶数)
int mass = 8;

//色
color usedButton = #8d5c99;

//マス管理用の二次元リスト
int [][] a = new int [mass][mass];

//一個前の配列を記録しておく
int [][] b = new int [mass][mass];
//復帰用の配列保存
int [][][] c = new int [200][mass][mass];
//ログ用の配列
int whiteLog [] = new int [200];
int blackLog [] = new int [200];
String log [] = new String [200];

int turn = 0;
int risetCount = 0;
//判定用の値をターンで切り替え
int changeValue = 0;
int unit = 600/mass;

//碁盤だけを描画
void greenBack() {
  fill(60, 255, 60);
  rect(0, 0, 600, 600);
  fill(0);
  for (int i=0; i<600; i+=(600/mass)) {
    line(i, 0, i, 600);
    line(0, i, 600, i);
  }
}

//配列情報をもとに石の状態を更新
//10だったら黒、1だったら白
void updateStones() {
  for (int j=0; j<mass; j++) {
    for (int i=0; i<mass; i++) {
      if (a[j][i] == 10) {
        fill(0);
        //circle((600/mass/2)+i*(600/mass), (600/mass/2)+j*(600/mass), (600/mass)*0.9);
        ellipseMode(CENTER);
        ellipse((600/mass/2)+i*(600/mass), (600/mass/2)+j*(600/mass), (600/mass)*0.9, (600/mass)*0.9);
      } else if (a[j][i] == 1) {
        fill(255);
        //circle((600/mass/2)+i*(600/mass), (600/mass/2)+j*(600/mass), (600/mass)*0.9);
        ellipseMode(CENTER);
        ellipse((600/mass/2)+i*(600/mass), (600/mass/2)+j*(600/mass), (600/mass)*0.9, (600/mass)*0.9);
      }
    }
  }
}

//配列の初期配置設定
void setListofFirstStone() {
  a[mass/2][mass/2] = 10-changeValue;
  a[mass/2-1][mass/2-1] = 10-changeValue;
  a[mass/2-1][mass/2] = 1+changeValue;
  a[mass/2][mass/2-1] = 1+changeValue;
}

//配列のコピー(aにbを代入する)
void listCopy(int a[][], int b[][]) {
  for (int j=0; j<mass; j++) {
    for (int i=0; i<mass; i++) {
      a[i][j] = b[i][j];
    }
  }
}


//判定（白プレイヤ―の時）
//(j,i)を中心に(n,m)方向への判定
//例：（-1,-1）だったら左下への判定
int sum;
int sum2;
int tmp;
int frag;
void judgeDirection(int j, int i, int n, int m) {
  listCopy(b, a);
  a[j][i] = 1+changeValue;
  //println(j, i);
  sum = 0;
  sumDirection(j, i, n, m);
  tmp = sum;
  //println("tmp = " + tmp);
  frag = 0;
  reverseStones(j, i, n, m);
  sum = 0;
  sumDirection(j, i, n, m);
  //println("sum = " + sum);
  //最後に白になってないor合計が不変の時はリセット
  if (frag == 0 || sum == tmp) {
    listCopy(a, b);
    risetCount++;
  }
}

//(n,m)方向への合計値
void sumDirection(int j, int i, int n, int m) {
  if (0<=j && j<mass && 0<=i && i<mass) {
    sum += a[j][i];
    //print(j, i + " ");
    //println(sum);
    sumDirection(j+n, i+m, n, m);
  }
}

//(n,m)方向へひっくり返す
void reverseStones(int j, int i, int n, int m) {
  //println(j, i);
  if (0<=j+n && j+n<mass && 0<=i+m && i+m<mass) {
    if (a[j+n][i+m]==10-changeValue) {
      a[j+n][i+m] = 1+changeValue;
      reverseStones(j+n, i+m, n, m);
    } else if (a[j+n][i+m] == 1+changeValue) {
      frag = 1;
    }
  }
}

void judge(int j, int i) {
  judgeDirection(j, i, 0, 1);//右
  judgeDirection(j, i, 1, 1);//右下
  judgeDirection(j, i, 1, 0);//下
  judgeDirection(j, i, 1, -1);//左下
  judgeDirection(j, i, 0, -1);//左
  judgeDirection(j, i, -1, -1);//左上
  judgeDirection(j, i, -1, 0);//上
  judgeDirection(j, i, -1, 1);//右上
}


//3次元配列にログとして盤面を保存する
//基本的にはsaveMassStatus(c,n,a);で使う
void saveMassStatus(int [][][] a, int n, int [][] b) {
  for (int i=0; i<mass; i++) {
    for (int j=0; j<mass; j++) {
      a[n][i][j] = b[i][j];
    }
  }
}

//ログからの復帰（上書き）
//loadMassStatus(a,c,n);で使う
void loadMassStatus(int [][] a, int [][][]b, int n) {
  for (int i=0; i<mass; i++) {
    for (int j=0; j<mass; j++) {
      a[i][j] = b[n][i][j];
    }
  }
}

//石の個数を数えて保存する
void saveStone() {
  int blackCount = 0;
  int whiteCount = 0;
  for (int i=0; i<mass; i++) {
    for (int j=0; j<mass; j++) {
      if (a[i][j] == 1) {
        whiteCount++;
      } else if (a[i][j] == 10) {
        blackCount++;
      }
    }
  }
  whiteLog[turn] = whiteCount;
  blackLog[turn] = blackCount;
  //println("white: " + whiteCount + " black: " + blackCount);
  //println("whiteLog[" +turn + "]:" + whiteLog[turn] + " blackLog[" +turn + "]:" + blackLog[turn]);
  //println("差 white:" + (whiteLog[turn]-whiteLog[turn-1]) + " black:" + (blackLog[turn]-blackLog[turn-1]));
}
void saveLog(int i, int j) {
  log[turn] = "ターン"+turn;
  if (turn%2==1)log[turn] += " 白";
  if (turn%2==0)log[turn] += " 黒";
  log[turn] += "("+i+","+j+") " + "白"+whiteLog[turn] + " 黒"+blackLog[turn];
  //println(log[turn]);
}

int logCount=0;
void turnLogDraw() {
  //ターン表示
  fill(55);
  rect(600, 0, 300, 60);
  textSize(28);
  fill(255);
  if (turn%2==0)text("白プレイヤーの番です", 600, 50);
  if (turn%2==1) text("黒プレイヤーの番です", 600, 50);
  //log表示
  textSize(20);
  fill(30);
  rect(610, 100, 280, 360);
  fill(255);
  if (turn>17)logCount++;
  for (int i=1+logCount; i<=turn; i++) {
    text(log[i], 610, 110+(i-logCount)*20);
  }
}

//void setup()内に書いてたやつ
void initProcess() {
  //背景
  background(55);
  //碁盤は600×600に作成
  greenBack();
  //最初の4石を配置して更新
  setListofFirstStone();
  updateStones();

  //盤面状態を保存
  saveMassStatus(c, 0, a);
  whiteLog[0] = 2;
  blackLog[0] = 2;

  //skipボタンの描画
  fill(#4deaff);
  rect(635, 535, 100, 50);
  fill(0);
  textSize(40);
  text("pass", 643, 575);
  //ターン表示
  fill(55);
  rect(600, 0, 300, 60);
  textSize(28);
  fill(255);
  text("白プレイヤーの番です", 600, 50);
  //ログの表示
  textSize(20);
  text("ログ", 600, 90);
  fill(30);
  rect(610, 100, 280, 360);

  //ロードボタンの描画
  fill(#ff9933);
  rect(765, 535, 100, 50);
  fill(0);
  textSize(40);
  text("load", 773, 575);

  //必殺技1ボタンの描画
  fill(#e478ff);
  rect(635, 475, 100, 50);
  fill(0);
  textSize(40);
  text("skill1", 638, 515);

  //必殺技2ボタンの描画
  fill(#e478ff);
  rect(765, 475, 100, 50);
  fill(0);
  textSize(40);
  text("skill2", 768, 515);
}

//四角制圧
void skill1() {
  a[0][0] = 1+changeValue;
  a[0][mass-1] = 1+changeValue;
  a[mass-1][0] = 1+changeValue;
  a[mass-1][mass-1] = 1+changeValue;
}

//天変地異
void skill2() {
  for (int i=0; i<mass; i++) {
    for (int j=0; j<mass; j++) {
      if (a[i][j] == 1) {
        a[i][j] = 10;
      } else if (a[i][j] == 10) {
        a[i][j] = 1;
      }
    }
  }
}

//四面楚歌
void skill3() {
  for (int i=1; i<mass-1; i++) {
    a[1][i] = 1+changeValue;
    a[mass-2][i] = 1+changeValue;
    a[i][1] = 1+changeValue;
    a[i][mass-2] = 1+changeValue;
  }
}

//雲散霧消
void skill4() {
  //左にずらす
  for (int j=0; j<mass/2-1; j++) {
    for (int i=1; i<mass-1; i++) {
      a[i][j] = a[i][j+1];
    }
  }
  //右にずらす
  for (int j=mass-1; j>mass/2; j--) {
    for (int i=1; i<mass-1; i++) {
      a[i][j] = a[i][j-1];
    }
  }
  //上にずらす
  for (int j=0; j<mass/2-1; j++) {
    for (int i=0; i<mass; i++) {
      a[j][i] = a[j+1][i];
    }
  }
  //下にずらす
  for (int j=mass-1; j>mass/2; j--) {
    for (int i=0; i<mass; i++) {
      a[j][i] = a[j-1][i];
    }
  }

  //中心を消す
  for (int j=mass/2-1; j<=mass/2; j++) {
    for (int i=0; i<mass; i++) {
      a[j][i] = 0;
      a[i][j] = 0;
    }
  }

  //中心に配置
  setListofFirstStone();
  //流石にこれないとクソゲーなので

  //碁盤を再描画
  greenBack();
}

//裏切り
int skill5Frag = 0;
void skill5() {
  skill5Frag = 1;
}

//スキル発動をやりやすくするだけ
void skill(int n) {
  switch(n)
  {
    case 1:
      skill1();
      break;
    case 2:
      skill2();
      break;
    case 3:
      skill3();
      break;
    case 4:
      skill4();
      break;
    case 5:
      skill5();
      break;
    default:
      break;
  }

  //println("skill" + n + "発動!");
}

//ログに技の名前を記載するよう
String skillName [] = new String [skillNumber+1];
//スキルの詳細
String skillDetail [] = new String [skillNumber+1];

//skill後の調整(1～4の時)
void adjustAfterSkill(int n, int skillNumber) {
  updateStones();
  turn++;
  saveStone();

  if (turn%2==0)changeValue=0;
  if (turn%2==1)changeValue=9;
  log[turn] = "ターン"+turn;
  if (turn%2==1)log[turn] += " 白";
  if (turn%2==0)log[turn] += " 黒";
  log[turn] += " skill"+skillNumber;
  log[turn] += skillName[n];

  saveMassStatus(c, turn, a);
  turnLogDraw();
}
//5の時
void adjustAfterSkill2(int skillNumber) {
  /*
  log[turn] = "ターン"+turn;
   if (turn%2==1)log[turn] += " 白";
   if (turn%2==0)log[turn] += " 黒";
   log[turn] = "skill"+skillNumber;
   log[turn] += skillName[5];
   */
  askillNumber = skillNumber;
}
int askillNumber;

//ボタンを再描画
void buttonRedraw() {
  //skipボタンの描画
  fill(#4deaff);
  rect(635, 535, 100, 50);
  fill(0);
  textSize(40);
  text("pass", 643, 575);

  //ロードボタンの描画
  fill(#ff9933);
  rect(765, 535, 100, 50);
  fill(0);
  textSize(40);
  text("load", 773, 575);

  //ログの表示
  fill(255);
  textSize(20);
  text("ログ", 600, 90);
  fill(30);
  rect(610, 100, 280, 360);

  //skillボタンの描画
  //whiteslill1等が0であれば描画しない
  //白プレイヤーの時
  if (turn%2==0) {
    //必殺技1ボタンの描画
    if (whiteskill1 == 0)fill(usedButton);
    if (whiteskill1 != 0)fill(#e478ff);
    rect(635, 475, 100, 50);
    fill(0);
    textSize(40);
    text("skill1", 638, 515);

    //必殺技2ボタンの描画
    if (whiteskill2 == 0)fill(usedButton);
    if (whiteskill2 != 0)fill(#e478ff);    
    rect(765, 475, 100, 50);
    fill(0);
    textSize(40);
    text("skill2", 768, 515);

    //黒プレイヤーの時
  } else if (turn%2==1) {

    //必殺技1ボタンの描画
    if (blackskill1 == 0)fill(usedButton);
    if (blackskill1 != 0)fill(#e478ff);
    rect(635, 475, 100, 50);
    fill(0);
    textSize(40);
    text("skill1", 638, 515);

    //必殺技2ボタンの描画
    if (blackskill2 == 0)fill(usedButton);
    if (blackskill2 != 0)fill(#e478ff);
    rect(765, 475, 100, 50);
    fill(0);
    textSize(40);
    text("skill2", 768, 515);
  }
}

//技演出用に画面を再描画する関数
void reDraw() {
  background(55);
  //碁盤を描画
  greenBack();
  //石を描画
  updateStones();
  //ログを描画
  fill(55);
  rect(600, 0, 300, 60);
  textSize(28);
  fill(255);
  if (turn%2==0)text("白プレイヤーの番です", 600, 50);
  if (turn%2==1) text("黒プレイヤーの番です", 600, 50);

  //ボタンを再描画
  buttonRedraw();

  //log表示
  textSize(20);
  fill(30);
  rect(610, 100, 280, 360);
  fill(255);
  for (int i=1+logCount; i<=turn; i++) {
    text(log[i], 610, 110+(i-logCount)*20);
  }
}

//残り何マスかを返してくれる関数
int vacantNumber() {
  int sum = 0;
  for (int i=0; i<mass; i++) {
    for (int j=0; j<mass; j++) {
      if (a[i][j] == 0) {
        sum++;
      }
    }
  }
  return sum;
}

//初期画面　タイトルclickToStart
void startScreen() {
  background(40);
  fill(255);
  textSize(80);
  text("Ultimate Reversi", 115, 250);
  textSize(30);
  text("click to start", 365, 400);
}

//ルール説明
void introduction() {
  //ルールはオセロと同じ
  //互いに2つの特殊なスキルを持つぞ！
  //これからその特殊スキルを開示するぞ！
  //1人目のプレイヤーだけが次の画面を見てくれ！
  //Click to next page
  background(40);
  textSize(80);
  text("Explanation", 210, 180);
  textSize(40);
  int head = 35;
  text("基本的なルールはオセロと同じ", head, 270);
  text("互いに2つの特殊なスキルを持つぞ！", head, 320);
  text("これからその特殊スキルを開示するぞ！", head, 370);
  text("1人目のプレイヤーだけが次の画面を見てくれ！", head, 420);
  text("クリックで次へ", 290, 500);
}

int ws1;
int ws2;
int bs1;
int bs2;

void playerSkillView1() {
  background(40);
  //println(ws1, ws2);
  //説明画像の描画
  skillImageDraw(ws1, 80, 200);
  skillImageDraw(ws2, 500, 200);
  //プレイヤ―表示
  fill(255);
  rect(50, 45, 500, 50);
  fill(0);
  textSize(50);
  text("白プレイヤーのスキル", 50, 90);
  fill(255);
  textSize(40);
  text("skill 1", 50, 180);
  text("skill 2", 470, 180);
  text(skillName[ws1], 145, 400);
  text(skillName[ws2], 565, 400);
  //スキルの詳細説明
  textSize(30);
  textAlign(CENTER);
  text(skillDetail[ws1], 250, 450);
  text(skillDetail[ws2], 670, 450);
  text("確認が終わったらクリック", 450, 570);
  textAlign(LEFT);
}

void playerSkillView2() {
  background(40);

  //println(bs1, bs2);
  //説明画像の描画
  skillImageDraw(bs1, 80, 200);
  skillImageDraw(bs2, 500, 200);
  //プレイヤ―表示
  fill(0);
  rect(50, 45, 500, 50);
  fill(255);
  textSize(50);
  text("黒プレイヤーのスキル", 50, 90);
  fill(255);
  textSize(40);
  text("skill 1", 50, 180);
  text("skill 2", 470, 180);
  text(skillName[bs1], 145, 400);
  text(skillName[bs2], 565, 400);
  //スキルの詳細説明
  textSize(30);
  textAlign(CENTER);
  text(skillDetail[bs1], 250, 450);
  text(skillDetail[bs2], 670, 450);
  text("確認が終わったらクリックしてゲームスタート！", 450, 570);
  textAlign(LEFT);
}

//skill説明画像描画
//skillの数 x座標 y座標
void skillImageDraw(int skill, int x, int y) {
  if (skill == 1) {
    image(defaultMass, x, y, 150, 150);
    image(skill1, x+170, y, 150, 150);
  } else if (skill == 2) {
    image(skill2_1, x, y, 150, 150);
    image(skill2_2, x+170, y, 150, 150);
  } else if (skill == 3) {
    image(defaultMass, x, y, 150, 150);
    image(skill3, x+170, y, 150, 150);
  } else if (skill == 4) {
    image(skill4_1, x, y, 150, 150);
    image(skill4_2, x+170, y, 150, 150);
  } else if (skill == 5) {
    image(skill5_1, x, y, 150, 150);
    image(skill5_2, x+170, y, 150, 150);
  }
}

PImage defaultMass;
PImage skill1;
PImage skill2_1;
PImage skill2_2;
PImage skill3;
PImage skill4_1;
PImage skill4_2;
PImage skill5_1;
PImage skill5_2;

void setup() {
  skillName[1] = " 四角制圧";//四つ角をとる
  skillName[2] = " 天変地異";//白黒を反転させる
  skillName[3] = " 四面楚歌";//縁を除いて□を作る
  skillName[4] = " 雲散霧消";//四隅に散る
  skillName[5] = " 排撃謀反";//相手の駒の上に置けるようになる
  skillDetail[1] = "四つ角を\n制圧できるぞ！";
  skillDetail[2] = "白と黒を\n反転できるぞ！";
  skillDetail[3] = "□で囲むぞ！";
  skillDetail[4] = "石を四隅に\n散らばらせるぞ！";
  skillDetail[5] = "相手の駒の上に\n置けるぞ！";
  //skillName[6] = " 天罰";//雲散霧消の×版
  //skillName[7] = " 蟻地獄";//右回転左回転
  //skillName[8] = " 牙城陥落";//四面楚歌を消す
  //skillName[9] = " 時間遡行";//相手の手を取り消す（一個前に戻る）（相手のskillを打ち消す）

  //説明画像のロード
  defaultMass = loadImage("default.jpg");
  skill1 = loadImage("skill1.jpg");
  skill2_1 = loadImage("skill2_1.jpg");
  skill2_2 = loadImage("skill2_2.jpg");
  skill3 = loadImage("skill3.jpg");
  skill4_1 = loadImage("skill4_1.jpg");
  skill4_2 = loadImage("skill4_2.jpg");
  skill5_1 = loadImage("skill5_1.jpg");
  skill5_2 = loadImage("skill5_2.jpg");

  //技の決定
  while (whiteskill1 == whiteskill2) {
    whiteskill1 = int(random(skillNumber))+1;
    whiteskill2 = int(random(skillNumber))+1;
  }
  //技の決定
  while (blackskill1 == blackskill2) {
    blackskill1 = int(random(skillNumber))+1;
    blackskill2 = int(random(skillNumber))+1;
  }
  ws1 = whiteskill1;
  ws2 = whiteskill2;
  bs1 = blackskill1;
  bs2 = blackskill2;

  PFont font = createFont("Meiryo", 50);
  textFont(font);
  //マスが奇数だったら終了
  if (mass%2 != 0)exit();
  //キャンバスを描画
  size(900, 600);

  //初期画面
  startScreen();
  mode++;
  //初期設定
  //initProcess();
}

//技の演出はこの中で書く
void draw() {
}

int loadFrag = 0;
int introStage = 1;

void mouseReleased() {

  //説明画面
  if (mode == 1) {
    if (introStage == 1) {
      //説明
      introduction();
    } else if (introStage == 2) {
      //1人目の技
      playerSkillView1();
    } else if (introStage == 3) {
      background(40);
      textSize(40);
      textAlign(CENTER);
      text("2人目のプレイヤーの技を公開するぞ！\n2人目だけが次の画面を見てくれ！", 450, 250);
      textSize(30);
      text("クリックして次の画面へ", 450, 450);
      textAlign(LEFT);
    } else if (introStage == 4) {
      //2人目の技
      playerSkillView2();
    } else if (introStage == 5) {
      //メイン画面に移行、準備
      mode++;
      initProcess();
    }
    introStage++;
  }


  if (mode == 2) {

    //判定
    int x = mouseX;
    int y = mouseY;
    for (int j=0; j<mass; j++) {
      for (int i=0; i<mass; i++) {
        if (i*unit<x && x<(i+1)*unit && j*unit<y && y<(j+1)*unit) {
          if (a[j][i]==0) {
            risetCount = 0;
            judge(j, i);
            if (risetCount!=8) {
              //println((8-risetCount)+"方向の有効判定");
              turn++;
              //println("turn = "+turn);
              if (turn%2==0)changeValue=0;
              if (turn%2==1)changeValue=9;
              updateStones();

              saveStone();
              saveLog(i, j);
              saveMassStatus(c, turn, a);
              //ターン表示
              turnLogDraw();
            }
          }
          //skill5用の条件分岐
          if (skill5Frag == 1) {
            if (a[j][i] != 1+changeValue) {
              risetCount = 0;
              judge(j, i);
              if (risetCount!=8) {
                //println((8-risetCount)+"方向の有効判定");
                turn++;
                //println("turn = "+turn);
                if (turn%2==0)changeValue=0;
                if (turn%2==1)changeValue=9;
                updateStones();

                saveStone();
                saveLog(i, j);
                saveMassStatus(c, turn, a);
                //ターン表示           
                log[turn] = "ターン"+turn;
                if (turn%2==1)log[turn] += " 白";
                if (turn%2==0)log[turn] += " 黒";
                log[turn] += "skill"+askillNumber;
                log[turn] += skillName[5];
                turnLogDraw();
              }
              skill5Frag = 0;
            }
          }
        }
      }
    }

    //skipボタン
    if (635<x && x<735 && 535<y && y<585) {
      turn++;
      //print("skiped ");
      //println("turn = "+turn);
      saveStone();
      if (turn%2==0)changeValue=0;
      if (turn%2==1)changeValue=9;
      log[turn] = "passed";
      saveMassStatus(c, turn, a);
      turnLogDraw();
    }

    //loadボタン
    if (765<x && x<865 && 535<y && y<585) {
      loadFrag = 1;
      fill(55);
      rect(600, 0, 300, 60);
      textSize(18);
      fill(255);
      text("読み込むlogをクリックして下さい", 600, 50);
    }
    //load
    if (loadFrag == 1) {
      if (610<x && x<870) {
        for (int i=0; i<turn-logCount; i++) {
          if (110+20*(i) < y && y < 130+20*(i)) {
            if (i%2==turn%2)turn++;

            //println("loaded " + (i+1+logCount));
            //println("turn = "+turn);
            saveStone();
            if (turn%2==0)changeValue=0;
            if (turn%2==1)changeValue=9;
            log[turn] += " ld "+(i+1)+" ";

            loadMassStatus(a, c, i+1+logCount);
            saveMassStatus(c, turn, a);

            greenBack();
            updateStones();
            turnLogDraw();

            loadFrag = 0;
          }
        }
      }
    }

    //skill1ボタン
    if (635<x && x<735 && 475<y && y<525) {
      print("skill1 did ");
      //println("turn = "+turn);

      //println("whiteskill1" + whiteskill1);
      //println("blackskill1" + blackskill1);

      //白プレイヤーの時
      if (turn%2==0) {

        if(whiteskill1 != 0)
        {
          //println("whiteskill1 != 0");
          skill(int(whiteskill1));
          if (whiteskill1!=5)
          {
            adjustAfterSkill(whiteskill1, 1);
          }
          else if(whiteskill1==5)
          {
            adjustAfterSkill2(1);
          } 
          whiteskill1 = 0;
        }

        /*
        for (int i=1; i<=skillNumber; i++) {
          if (whiteskill1 == i) {
            skill(i);
            if (i!=5)
            {
              adjustAfterSkill(i, 1);
            }
            else if(i==5)
            {
              adjustAfterSkill2(1);
            } 
            whiteskill1 = 0;
          }
        }
        */

        //黒プレイヤーの時
      } else if (turn%2==1) {

        if(blackskill1 != 0)
        {
          skill(blackskill1);
          if (blackskill1!=5)
          {
            adjustAfterSkill(blackskill1, 1);
          }
          else if(blackskill1==5)
          {
            adjustAfterSkill2(1);
          } 
          blackskill1 = 0;
        }

        /*
        for (int i=1; i<=skillNumber; i++) {
          if (blackskill1 == i) {
            skill(i);
            if (i!=5)
            {
              adjustAfterSkill(i, 1);
            }
            else if(i==5)
            {
              adjustAfterSkill2(1);
            } 
            blackskill1 = 0;
          }
        }
        */
      }
    }
    //skill2ボタン
    if (765<x && x<865 && 475<y && y<525) {
      print("skill2 did ");
      //println("turn = "+turn);

      //println("whiteskill2" + whiteskill2);
      //println("blackskill2" + blackskill2);

      //白プレイヤーの時
      if (turn%2==0) {
        for (int i=1; i<=skillNumber; i++) {
          if (whiteskill2 == i) {
            skill(i);
            if (i!=5)
            {
              adjustAfterSkill(i, 2);
            }
            else if(i==5)
            {
              adjustAfterSkill2(2);
            }
            whiteskill2 = 0;
          }
        }
        //黒プレイヤーの時
      } else if (turn%2==1) {
        for (int i=1; i<=skillNumber; i++) {
          if (blackskill2 == i) {
            skill(i);
            if (i!=5)
            {
              adjustAfterSkill(i, 2);
            }
            else if (i==5)
            {
              adjustAfterSkill2(2);
            }
            blackskill2 = 0;
          }
        }
      }
    }
    //println(x, y);
    reDraw();
  }
}

int skillReview = 0;

//デバッグ用
void keyPressed() {
  //押されたキーを判定する
  switch( key ) {
  case ENTER:
  case RETURN:
    //println( "ENTERキーが押された" );
    reDraw();
    break;
  case BACKSPACE:
    //println( "BACKSPACEキーが押された" );
    break;
  case TAB:
    //println( "TABキーが押された" );
    break;
  case DELETE:
    //println( "DELETEキーが押された" );
    //println(vacantNumber());
    break;
  case ' ':
    //println( "SPACEキーが押された");
    if (skillReview %2 ==  0 && mode == 2) {
      if (turn%2==0)playerSkillView1();
      if (turn%2==1)playerSkillView2();
    } else if (mode == 2) {
      reDraw();
    }
    skillReview++;
    break;
  default:
    //println( key + "が押された" );
    break;
  }
}
