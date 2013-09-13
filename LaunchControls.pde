/* controls for the launch scene */

public class LaunchControl extends PanelSet {
  
  boolean gravOn = true;
  boolean clampOn = true;
  boolean grabberState = false;
  
  public LaunchControl(String name, PApplet parent, OscP5 p5, ControlP5 cp5){
    super(name, parent, p5, cp5);
  }
  
  public void draw(){
    textFont(font,12);
    text("docking grabber can be used? : " + grabberState, 100,200);
  }
  
  
  public void initGui(){
    cp5.addTextlabel("label")
      .setText("SCRIPT ----------------\r\n1. captain tells the crew to start ship up and open blast door\r\n2. once started hit the 'start launch sequence' button, this puts them in the launch tube\r\n3. turn off gravity and release the clamp\r\n4. open the bay doors when they have requested clearance\r\nJOB DONE!")
      
      
      .setPosition(12,50)
      .setColorValue(0xffffff00)
      .setFont(createFont("Georgia",15))
      .moveTo(name)
      ;
    
    
    //controls for:
   
    // front door open 
   cp5.addBang("BayDoors")
     .setPosition(280, 300)
     .setSize(50, 50)
     .setTriggerEvent(Bang.RELEASE)
     .setLabel("Open Bay Doors")
     .moveTo(name)
     ;
     //gravity
     cp5.addToggle("Bay Gravity")
     .setPosition(120, 300)
     .setSize(50, 50)
     .setLabel("Bay Gravity")
     .setValue(1.0f)
     .moveTo(name)
     ;
     
     cp5.addBang("StartLaunch")
     .setPosition(40, 300)
     .setSize(50, 50)
     .setLabel("Start launch\r\nsequence")
     .setValue(1.0f)
     .moveTo(name)
     ;
     
      cp5.addToggle("DockingClamp")
     .setPosition(200, 300)
     .setSize(50, 50)
     .setLabel("Docking\r\nClamp")
     .setValue(1.0f)
     .moveTo(name)
     ;
     
      cp5.addToggle("SpawnMissile")
     .setPosition(360, 300)
     .setSize(50, 50)
     .setLabel("Spawn Training\r\nMissiles?")
     .setValue(0.0f)
     .moveTo(name)
     ;
     
     cp5.addToggle("HighlightGate")
     .setPosition(440, 300)
     .setSize(50, 50)
     .setLabel("Target\r\nGate?")
     .setValue(0.0f)
     .moveTo(name)
     ;
     
    
  }
  
  public void oscMessage(OscMessage msg){
  
    if (msg.checkAddrPattern("/scene/launchland/grabberState") == true) {
      grabberState = msg.get(0).intValue() == 1 ? true : false;
    }
  
  }
  public void controlEvent(ControlEvent theControlEvent) {
    if(theControlEvent.getName().equals("BayDoors")){
      // /scene/dockingBay 1
      OscMessage m  = new OscMessage("/scene/launchland/dockingBay");
      m.add(1);
      oscP5.send(m, myRemoteLocation);
    } else if(theControlEvent.getName().equals("Bay Gravity")){
      OscMessage m  = new OscMessage("/scene/launchland/bayGravity");
      m.add( (int)theControlEvent.getValue() );
      oscP5.send(m, myRemoteLocation);
    } else if(theControlEvent.getName().equals("StartLaunch")){
      OscMessage m  = new OscMessage("/scene/launchland/startLaunch");
      oscP5.send(m, myRemoteLocation);
    } else if(theControlEvent.getName().equals("DockingClamp")){
      OscMessage m  = new OscMessage("/system/misc/dockingClamp");
      m.add( (int)theControlEvent.getValue() );
      oscP5.send(m, myRemoteLocation);
    } else if(theControlEvent.getName().equals("SpawnMissile")){
      OscMessage m  = new OscMessage("/scene/launchland/trainingMissiles");
      m.add( (int)theControlEvent.getValue() );
      oscP5.send(m, myRemoteLocation);
    } else if(theControlEvent.getName().equals("HighlightGate")){
      OscMessage m  = new OscMessage("/scene/launchland/targetGate");
      m.add( (int)theControlEvent.getValue() );
      oscP5.send(m, myRemoteLocation);
    }

  
  
  }
  
}
