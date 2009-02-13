/*
 * 脳トレ風16進数演算トレーニング
 * 
 * by twface - twface@livedoor.com
 * LISENCE: MIT
 */
package {
  import flash.events.*;
  import flash.text.*;
  import flash.display.Sprite;
  import flash.ui.Keyboard;
  import flash.utils.Timer;
  import flash.utils.getTimer;
  import mx.utils.StringUtil;

  [SWF(width="600", height="600", backgroundColor="0xffffff", frameRate="15")]

  /**
   * ゲーム基本クラス
   */
  public class HexOperators extends Sprite {

    /// フォント
    [Embed(source="ipam.ttf", fontFamily="ipam")]
    private var ipam:Class;

    // 答え保存配列
    private var answers:Array;
    // 何問目か
    private var answerIndex:uint;

    // ゲーム開始時刻
    private var startedAt:int;
    // メインタイマー
    private var gameTimer:Timer;

    // 問題を描画するSprite
    private var questionSprite:Sprite;

    public function HexOperators() {
      mouseEnabled = false;
      tabEnabled   = false;

      spriteInit();
      createQuestion();
      gameStart();
    }

    // ゲームのリスタート
    public function appRestart():void {
      spriteReload();
      createQuestion();
      gameStart();
    }

    // questionSprite の初期化
    private function spriteInit():void {
      questionSprite = new Sprite();
      questionSprite.y = 200;
      questionSprite.mouseEnabled = false;
      questionSprite.tabEnabled   = false;
      questionSprite.alpha = 0.2;
      addChild(questionSprite);
    }

    // questionSprite の再初期化
    private function spriteReload():void {
      removeChild(questionSprite);
      spriteInit();
    }

    // 問題を作成して questionSprite に書き、
    // 答えを answers に入れる
    private function createQuestion():void {
      answers = [];
      answerIndex = 0;
      var index:uint = 0;

      // 問題と答えのペアを登録する関数
      function registerQuestion(q:String, a:uint):void {
        var texty:uint = 100 * index;
        var field:TextField = newQuestionField(texty);
        var ans:TextField = newAnswerField(texty, a);
        field.appendText(q);

        ans.tabIndex = index;
        answers[index] = ans;

        questionSprite.addChild(field);
        questionSprite.addChild(ans);
        index++;
      }

      //var expr:Expression = new AddSubExpression(1.0);
      //var expr:Expression = new MulDivExpression(0.5);
      //var expr:Expression = new MulDivExpression(1.0);

      var iter:Level1Iterator = new Level1Iterator();
      //var iter:QIterator = new DebugIterator();
      while (iter.hasNext()) {
        var qa:Array = iter.question();
        registerQuestion(qa[0], qa[1]);
      }
    }

    // ゲームスタート
    private function gameStart():void {
      var startField:TextField = newOverallField();
      startField.alpha = 0.8;
      addChild(startField);

      var timer:Timer = new Timer(1000, 4);
      // カウントダウン
      timer.addEventListener(TimerEvent.TIMER, function(e:Event):void {
        startField.text = String(4 - e.target.currentCount);
      })
      // ゲームスタート処理
      timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:Event):void {
        startField.parent.removeChild(startField);
        questionSprite.alpha = 1.0;
        stage.focus = answers[0];
        startedAt = getTimer();
      })
      timer.start();
    }

    // ゲーム終了処理
    private function gameFinish():void {
      // 終了処理タイマ
      var finishedAt:int = getTimer();
      questionSprite.alpha = 0.2;

      var messages:Array = [
        '<p class="p1" style="font-size:200px;font-weight:bold;">終了</p>',
        StringUtil.substitute('<p class="p2">{0} 秒</p>', (finishedAt - startedAt) / 1000),
        StringUtil.substitute('<p class="p2">{0} 問中 <font color="#a00000">{0}</font> 問正解</p>', answers.length),
        '<p class="p3">クリックでリスタート</p>'
      ];
 
      function getMessages(messageNum:uint):String {
        return messages.slice(0, messageNum).join("<br>\n");
      }

      var resultField:TextField = new TextField();
      var style1:Object = {
        textAlign:  'center',
        fontSize:   '200px',
        fontWeight: 'bold'
      };
      var style2:Object = {
        textAlign: 'center',
        fontSize:  '75px'
      }
      var style3:Object = {
        textAlign: 'center',
        fontSize:  '20px'
      }
      var style:StyleSheet = new StyleSheet();
      style.setStyle(".p1", style1);
      style.setStyle(".p2", style2);
      style.setStyle(".p3", style3);

      var txtFmt:TextFormat = textFormat();
      resultField.x = 0;
      resultField.y = 120;
      resultField.width = 600;
      resultField.height = 480;
      resultField.embedFonts = true;
      resultField.defaultTextFormat = txtFmt;
      resultField.styleSheet = style;

      addChild(resultField);
      resultField.htmlText = getMessages(1);

      var t1:Timer = new Timer(1000,1);
      t1.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:Event):void {
        resultField.htmlText = getMessages(2);
      });
      var t2:Timer = new Timer(2000,1);
      t2.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:Event):void {
        resultField.htmlText = getMessages(4);
        resultField.addEventListener(MouseEvent.CLICK, function(e:Event):void {
          resultField.parent.removeChild(resultField);
          appRestart();
        });
      });
      t1.start();
      t2.start();
    }

    // 子のアプリでの標準テキストフォーマット
    private function textFormat():TextFormat {
      var txtFmt:TextFormat = new TextFormat();
      txtFmt.font = 'ipam';
      txtFmt.color = '0x000000';
      txtFmt.size = 100;
      return txtFmt;
    }

    // 問題が表示されるテキストフィールド
    private function newQuestionField(y:uint):TextField {
      var field:TextField = new TextField();
      field.width  = 400;
      field.height = 100;
      field.embedFonts = true;
      field.defaultTextFormat = textFormat();
      field.y = y;
      return field;
    }

    // 答えを入力する部分のテキストフィールド初期化
    private function newAnswerField(y:uint, ans:uint):TextField {
      var field:AnswerField = new AnswerField();
      field.type = TextFieldType.INPUT;
      field.x = 400;
      field.width  = 200;
      field.height = 100;
      field.embedFonts = true;
      field.defaultTextFormat = textFormat();
      field.y = y;
      field.answer = ans;
      field.addEventListener(Event.CHANGE, onAnswerChange);
      field.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onFocusEvent);
      field.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, onFocusEvent);
      return field;
    }

    private function newOverallField(): TextField {
      var txtFmt:TextFormat = textFormat();
      txtFmt.size = 300;
      txtFmt.align = TextFormatAlign.CENTER;
      txtFmt.bold = true;
      var field:TextField = new TextField();
      field.x = 0;
      field.y = 120;
      field.width = 600;
      field.height = 480;
      field.defaultTextFormat = txtFmt;
      return field;
    }

    // テキスト入力されたら正解を判定する。
    // 正解だったら次の問題へ
    private function onAnswerChange(e:Event):void {
      if (e.target.answer.toString(16) == e.target.text) {
        nextQuestion();
      }
    }

    // デフォルトのフォーカスイベントを止める。
    private function onFocusEvent(e:Event):void {
      e.preventDefault();
      focus(); // フォーカスをつけ直す
    }

    // 次の問題へ移動する
    public function nextQuestion():void {
      if (++answerIndex < answers.length) {
        focus();
        scroll();
      }
      else {
        gameFinish();
      }
    }

    // フォーカスを問題へ変更する
    private function focus():void {
      stage.focus = answers[answerIndex];
    }

    // 問題のスクロール
    private function scroll():void {
      questionSprite.y -= 100;
    }
  }
}

import flash.text.*;
import flash.events.*;
import mx.utils.StringUtil;

internal class AnswerField extends TextField {
  private var answerValue:uint;

  public function set answer(a:uint):void {
    answerValue = a;
  }
  public function get answer():uint {
    return answerValue;
  }
}

internal interface QIterator {
  function question():Array;
  function hasNext():Boolean;
}

internal class DebugIterator implements QIterator {
  private var firstTime:Boolean = true;
  public function DebugIterator() {
  }
  public function question():Array {
    firstTime = false;
    return ["1 + 1", 2];
  }
  public function hasNext():Boolean {
    return firstTime;
  }
}

internal class Level1Iterator implements QIterator {
  private var index:uint = 0;
  private var questions:Array = [];

  public function Level1Iterator() {

    var i:uint = 0;
    var expr:Expression = new EasyAddSubExpression(1.0);
    for ( ; i < 10; i++) {
      questions.push([expr.getExpression(), expr.getAnswer()]);
      expr.next();
    }
  }
  public function question():Array {
    return questions[index++];
  }

  public function hasNext():Boolean {
    return index < questions.length;
  }
}


internal class Level2Iterator implements QIterator {
  private var index:uint = 0;
  private var questions:Array = [];

  public function Level2Iterator() {
    var i:uint = 0;
    var expr:Expression = new EasyAddSubExpression(1.0);
    for ( ; i < 10; i++) {
      questions.push([expr.getExpression(), expr.getAnswer()]);
      expr.next();
    }
    expr = new EasyAddSubExpression(0.5);
    for ( ; i < 15; i++) {
      questions.push([expr.getExpression(), expr.getAnswer()]);
      expr.next();
    }
    expr = new EasyAddSubExpression(0.2);
    for ( ; i < 18; i++) {
      questions.push([expr.getExpression(), expr.getAnswer()]);
      expr.next();
    }
    expr = new AddSubExpression();
    for ( ; i < 20; i++) {
      questions.push([expr.getExpression(), expr.getAnswer()]);
      expr.next();
    }
  }
  public function question():Array {
    return questions[index++];
  }

  public function hasNext():Boolean {
    return index < questions.length;
    
  }
}


internal function format(i:int):String {
  return (i <= 0xf) ? " " + i.toString(16) : i.toString(16);
}

internal class Expression {
  protected var x:int;
  protected var y:int;
  protected var oper:String;
  //protected var expression:String;
  protected var answer:int;

  public function getExpression():String {
    return StringUtil.substitute("{0}{1}{2} = ", format(x), oper, format(y));
  }

  public function getAnswer():int {
    return answer;
  }

  public function next():void {
  }
  
}

// 1桁の加算
internal class EasyAddSubExpression extends Expression {
  private const MAX:uint = 0xf;
  private var addRate:Number;

  public function EasyAddSubExpression(rate:Number = 1.0) {
    addRate = rate;
    next();
  }
  override public function next():void {
    var a:int = int(Math.random() * MAX) + 1; // [0, 0xf) -> [1, 0xf]
    var b:int = int(Math.random() * MAX) + 1;
    if (Math.random() < addRate) {
      oper = '+';
      x = a;
      y = b;
      answer = x + y;
    }
    else {
      oper = '-';
      x = a + b;
      y = a;
      answer = b;
    }
  }
}

// 和が2桁までの加算, 減算
internal class AddSubExpression extends Expression {
  private const MAX_SUM:uint = 0xff;
  private var addRate:Number;

  public function AddSubExpression(rate:Number = 1.0) {
    addRate = rate;
    next();
  }
  override public function next():void {
    var a:int = int(Math.random() * (MAX_SUM-0x10)) + 0x11; // [0, 0xff-5) -> [6, 0xff]
    var b:int = int(Math.random() * (a-1)) + 1;
    // a - b = ? , b + ? = a
    if (Math.random() < addRate) { // add
      oper = '＋';
      x = b;
      y = a - b;
      answer = a;
    }
    else { // sub
      oper = '－';
      x = a;
      y = b;
      answer = a - b;
    }
  }
}

// 九九相当
internal class MulDivExpression extends Expression {
  private const MAX:uint = 0xf;
  private var mulRate:Number;

  public function MulDivExpression(rate:Number = 1.0) {
    mulRate = rate;
    next();
  }
  override public function next():void {
    var a:int = int(Math.random() * MAX) + 1; // [0, 0xf) -> [1, 0xf]
    var b:int = int(Math.random() * MAX) + 1;
    if (Math.random() < mulRate) { // mul
      oper = '×';
      x = a;
      y = b;
      answer = a * b;
    }
    else { // div
      oper = '÷';
      x = a * b;
      y = a;
      answer = b;
    }
  }
}

