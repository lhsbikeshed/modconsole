/* controls for the landing scene */

public class LandingControls extends PanelSet {
  
   boolean grabberState = false;
  
  public LandingControls(String name, PApplet parent, OscP5 p5, ControlP5 cp5){
    super(name, parent, p5, cp5);
  }
  
  public void draw(){
    textFont(font,12);
    text("docking grabber can be used? : " + grabberState, 100,200);
  }
  
  
  public void initGui(){
     cp5.addTextlabel("label2")
      .setText("SCRIPT ----------------\r\n1. wait for permission to land\r\n2.open bay doors\r\n3. toggle gravity on and off to be sure its off\r\n4. wait for 'can clamp be used' go to true and hit 'start docking crane'\r\n5.once the crane has stopped hit the clamp")      
      
      .setPosition(12,50)
      .setColorValue(0xffffff00)
      .setFont(createFont("Georgia",15))
      .moveTo(name)
      ;
      
    // front door open 
   cp5.addBang("BayDoors2")
     .setPosition(40, 300)
     .setSize(50, 50)
     .setTriggerEvent(Bang.RELEASE)
     .setLabel("Open Bay Doors")
     .moveTo(name)
     ;
     //gravity
     cp5.addToggle("Bay Gravity2")
     .setPosition(120, 300)
     .setSize(50, 50)
     .setLabel("Bay Gravity")
     .setValue(1.0f)
     .moveTo(name)
     ;
     
     cp5.addBang("StartDock")
     .setPosition(200, 300)
     .setSize(50, 50)
     .setLabel("Start docking\r\ncrane")
     .setValue(1.0f)
     .moveTo(name)
     ;
     
      cp5.addToggle("DockingClamp2")
     .setPosition(280, 300)
     .setSize(50, 50)
     .setLabel("Docking\r\nClamp")
     .setValue(1.0f)
     .moveTo(name);
     
      cp5.addBang("GameWin")
     .setPosition(360, 300)
     .setSize(50, 50)
     .setLabel("Win Game")
     .moveTo(name);
  }
  
  
  public void oscMessage(OscMessage msg){
  
  
    if (msg.checkAddrPattern("/scene/launchland/grabberState") == true) {
      grabberState = msg.get(0).intValue() == 1 ? true : false;
    }
  
  }
  
  
  public void controlEvent(ControlEvent theControlEvent) {
   if(theControlEvent.getName().equals("BayDoors2")){
      // /scene/dockingBay 1
      OscMessage m  = new OscMessage("/scene/launchland/dockingBay");
      m.add(1);
      oscP5.send(m, myRemoteLocation);
    } else if(theControlEvent.getName().equals("Bay Gravity2")){
      OscMessage m  = new OscMessage("/scene/launchland/bayGravity");
      m.add( (int)theControlEvent.getValue() );
      oscP5.send(m, myRemoteLocation);
    } else if(theControlEvent.getName().equals("DockingClamp2")){
      OscMessage m  = new OscMessage("/system/misc/dockingClamp");
      m.add( (int)theControlEvent.getValue() );
      oscP5.send(m, myRemoteLocation);
    } else if(theControlEvent.getName().equals("StartDock")){
      OscMessage m  = new OscMessage("/scene/launchland/startDock");
      oscP5.send(m, myRemoteLocation);
    } else if(theControlEvent.getName().equals("GameWin")){
      OscMessage m  = new OscMessage("/game/gameWin");
      oscP5.send(m, myRemoteLocation);
    }

  
  }
  
}
