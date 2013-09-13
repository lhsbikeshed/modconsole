/* controls for the hyper scene */

public class HyperControls extends PanelSet {
  
  int secondsUntilExit = 0;
  long exitTime = 0;
  boolean exiting = false;
  boolean failedExit = false;
  
  
  public HyperControls(String name, PApplet parent, OscP5 p5, ControlP5 cp5){
    super(name, parent, p5, cp5);
  }
  
  public void draw(){
    
    textFont(font,20);
    if(exiting){
      
      text("State : Exiting!", 60,230);
      text("exiting in: " + (secondsUntilExit*1000 - (millis() - exitTime)), 60,245);
      if(failedExit){
        text("FAILED JUMP - WARN PLAYERS OF ROUGH RIDE AND DAMAGE", 60,260);
      }
    } else {
      text("State : In Jump", 60,230);
    }
  
  }
  
  public void reset(){
    exiting = false;
    secondsUntilExit = 0;
    failedExit = false;
    exitTime = 0;
  }
  
  
  public void initGui(){
  
    cp5.addTextlabel(name+"label")
      .setText("SCRIPT ----------------\r\n1. Prompt engineer to look at screen and follow instructions \r\n2. IF WARNING OCCURS tell them were bailing out of jump early and to expect a rough ride")
      .setPosition(12,50)
      .setColorValue(0xffffff00)
      .setFont(createFont("Georgia",15))
      .moveTo(name)
      ;
  
  }
  
  public void oscMessage(OscMessage msg){
    /*
      /warpscene/failjump    x = seconds until exit
      /warpscene/exitjump
    */
    if(msg.checkAddrPattern("/scene/warp/failjump")){
      exiting = true;
      failedExit = true;
      secondsUntilExit = msg.get(0).intValue();
      exitTime = millis();
    } else if (msg.checkAddrPattern("/warpscene/exitjump")){
      exiting = true;
      failedExit = false;
      exitTime = millis();
      secondsUntilExit = msg.get(0).intValue();
    }
      
  
  }
  public void controlEvent(ControlEvent theControlEvent) {}
  
}
