

public class ShipStatePanel extends PanelSet {
  
  //states
  public boolean reactorState = false;
  public boolean rodState = false;
  public float hull = 0;
  public float jumpCharge = 0;
  public float oxygenLevel = 0;
  public int undercarriageState = 0;
  public int failureCount = 0;
  private String[] undercarriageStrings = {"up", "down", "Lowering..", "Raising.."};
  
  public boolean canClampBeEnabled = false;
  public boolean canJump = false;
  public boolean reactorOn = false;
  
  public boolean joystickEnabled = false;
  Joystick joy;
  
  //GUI crap
  DropdownList bgList, lightingList;
  Slider chromaSlider, lowerSlider, upperSlider, thSlider;
  
  String[] bangList = { "Start\r\nJump", "Damage\r\nShip", "smoke", "Reactor\r\nFailure", "Self\r\nDestruct", "stop SD", "Fix Stuck\r\nBoot?"};
  String[] bangMapping =  {"/system/jump/startJump","/ship/damage", "/lulz/smoke", "/system/reactor/fail", "/system/reactor/overload", "/system/reactor/overloadinterrupt",
                            "/system/boot/justFuckingBoot"
                          };
  /* toggle buttons and their osc messages */
  String[] toggleList = { "Reactor\r\nState", "Propulsion\r\nState", "JumpState", "ShipLight",  "BlastShield", "Enable\r\nautopilot",
                          "Tactical power", "Engineer power", "pilot Power", "comms power",
                          "Undercarriage", "Engineer\r\nFailures?", "Grappling\r\nHook\r\nArmed?"

                        };
  String[] toggleMapping = {"/system/reactor/setstate", "/system/propulsion/state", "/system/jump/state", "/system/misc/extlight",  "/system/misc/blastShield", "/system/control/controlState",
                            "/tactical/powerState", "/engineer/powerState", "/pilot/powerState","/comms/powerState", "/system/undercarriage/state", "/system/powerManagement/failureState",
                            "/control/grapplingHookState"  
                        };
  boolean[] defaultStates = {false, false, false, false, true, false,true,
                             false, false, false, false, true, false
                            };
  String[] bgNames = {"Instructor", "Warzone Ship", "aliens"};
  
  Knob engineerDiffKnob;
  
  
  boolean ready = false;
  PApplet parent;
  
  public ShipStatePanel(String name, PApplet parent, OscP5 p5, ControlP5 cp5, boolean useStick){
    super(name, parent, p5, cp5);
    this.parent = parent;
    joy = new Joystick(p5, parent, useStick);
    joy.setEnabled(false);
  }
  
  public void initGui(){
  
    // docking clamp
    // light
    // prop state
    // jump state
    // jump charge and jump button readyness
    // initiate jump
    
    //video calling controls
    cp5.addBang("VideoCallStart")
     .setPosition(20, 400)
     .setSize(50, 50)
     .setTriggerEvent(Bang.RELEASE)
     .setLabel("Start Call")     
     ;
     cp5.addBang("VideoCallEnd")
     .setPosition(80, 400)
     .setSize(50, 50)
     .setTriggerEvent(Bang.RELEASE)
     .setLabel("End Call")     
     ;
     chromaSlider = cp5.addSlider("chroma")
     .setPosition(150,413)
     .setRange(0,255)
     .setLabel("Hue Key")
     .setSize(200,10)
     ;
     upperSlider = cp5.addSlider("threshTop")
     .setPosition(150,433)
     .setRange(0,255)
     .setLabel("Sat. Threshold")
     .setSize(200,10)
     ;
     lowerSlider = cp5.addSlider("threshBot")
     .setPosition(150,453)
     .setRange(0,255)
     .setLabel("Sat Key")
     .setSize(200,10)
     ;
     thSlider = cp5.addSlider("threshSlider")
     .setPosition(150,473)
     .setRange(0,255)
     .setLabel("Hue Threshold")
     .setSize(200,10)
     ;
     
     
     
     // Backgrounds for vid calling
     bgList = cp5.addDropdownList("Video Call background")
         .setPosition(140, 410)
         .setSize(120, 120)
         .setItemHeight(20)
         .setBarHeight(20)
         .setColorActive(color(0))
         .setColorForeground(color(255, 100,0))
         ;
         
     for(int i = 0; i < bgNames.length; i++){
       ListBoxItem lbi = bgList.addItem(bgNames[i], i);
     }
     
     /* interior lighting control 
     char[] lightMap = {'i', 'w', 'r', 'b'}; */
     String[] lightNames  = {"Idle", "Warp", "red alert", "briefing"};
     
     lightingList = cp5.addDropdownList("Cabin Lighting")
         .setPosition(880, 480)
         .setSize(120, 100)
         .setItemHeight(20)
         .setBarHeight(20)
         .setColorActive(color(255))
         .setColorForeground(color(255, 100,0))
         ;
     for(int i = 0; i < lightNames.length; i++){
       ListBoxItem lbi = lightingList.addItem(lightNames[i], i);
     }
     cp5.addBang("SetLights")
     .setPosition(810, 460)
     .setSize(50, 25)
     .setTriggerEvent(Bang.RELEASE)
     .setLabel("Set Lights")     
     ;
     
     cp5.addToggle("LightPower")
         .setPosition(750,460)
         .setSize(50,25)
         .setLabel("light power")
         ;
     
     //bang list
     for (int i = 0; i < bangList.length; i++){
       cp5.addBang(bangList[i])
         .setPosition(20 + i * 55, 500)
         .setSize(35, 35)
         .setTriggerEvent(Bang.RELEASE)
         .setLabel(bangList[i])     
         ;
     }
     int cx = -40;
     int cy = 600;
     for(int i = 0; i < toggleList.length; i++){
       // system toggles
       cx += 70;
       if(cx > 500){
         cx = 30;
         cy += 50;
       }
       cp5.addToggle(toggleList[i])
         .setPosition(cx,cy)
         .setSize(50,20)
         .setState(defaultStates[i])
         ;
     }
     
     //player killer
     cp5.addTextfield("DeathReason")
     .setPosition(720,390)
     .setSize(200,30)
     .setFont(createFont("arial",12))
     .setAutoClear(false)
     ;
     
     cp5.addBang("KillShip")
     .setPosition(955, 390)
     .setSize(50, 50)
     .setTriggerEvent(Bang.RELEASE)
     .setLabel("Kill The Ship")     
     ;
     
      engineerDiffKnob = cp5.addKnob("Engineer\r\nDifficulty")
               .setRange(1,10)
               .setValue(1)
               .setPosition(920,650)
               .setRadius(30)
               .setNumberOfTickMarks(10)
               .setTickMarkLength(1)
               .snapToTickMarks(true)
               .setColorForeground(color(255))
               .setColorBackground(color(0, 160, 100))
               .setColorActive(color(255,255,0))
               .setDragDirection(Knob.HORIZONTAL)
                 
               ;
     
     
     ready = true;
  }
  
  
  public void draw(){
    joy.update();
    //y=380
    textFont(font, 12);
    pushMatrix();
    translate(10, 800);
    text("reactor On?: " + reactorState, 128,670);
    text("Can jump? : " + canJump, 128, 690);
    
    text("Hull Health: " + hull, 0, 0);
    text("o2 Level: " + oxygenLevel, 0, 20);
    text("Jump Charge: " + jumpCharge, 0, 40);
    text("Undercarriage: " + undercarriageStrings[undercarriageState], 0, 60);
    text("can clamp be used: " + canClampBeEnabled, 0, 80);
    if(failureCount >= 6){
      fill(255,0,0);
    } else {
      fill(255,255,255);
    }
    text("failed reactor systems: " + failureCount, 300,0);
    popMatrix();
  }
  public void oscMessage(OscMessage msg){
  
  
  }
  
  public void controlEvent(ControlEvent theControlEvent) {
    if(!ready) { return; }
    String name = theControlEvent.getName();
    
    /* do the toggle list first */
    try {
      Toggle t = (Toggle)theControlEvent.getController();
      
      for(int i = 0; i < toggleList.length; i++){
        if(toggleList[i].equals(name)){
           //get the state of the toggle
          int state = (int)theControlEvent.getValue();
          OscMessage msg = new OscMessage(toggleMapping[i]);
          
          msg.add(state);
          oscP5.send(msg, myRemoteLocation);
          
          if(toggleList[i].equals("Enable\r\nautopilot")){
            if(state == 1){
              println("turning stick on");
              joy.setEnabled(true);
            } else {
              println("Stick off");
              joy.setEnabled(false);
            }
          }
        }      
      } 
      
      if(name.equals("LightPower")){
        boolean state = (int)theControlEvent.getValue() == 1 ? true : false;
        setLightState(state);
      }
    } catch (ClassCastException e){}
    
    /* do the bang list first */
    try {
      Bang t = (Bang)theControlEvent.getController();
      
      for(int i = 0; i < bangList.length; i++){
        if(bangList[i].equals(name)){          
          OscMessage msg = new OscMessage(bangMapping[i]);
          oscP5.send(msg, myRemoteLocation);
            
        }      
      } 
      
      if(name.equals("KillShip") ){
        OscMessage msg = new OscMessage("/game/KillPlayers");
          
        msg.add(cp5.get(Textfield.class,"DeathReason").getText());
        oscP5.send(msg, myRemoteLocation);
      } else if (name.equals("SetLights")){
        int ind =(int) lightingList.getValue();
        setLightMode(ind);
      } else if (name.equals("VideoCallStart")){
        int bg = (int)bgList.getValue();
        OscMessage msg = new OscMessage("/clientscreen/CommsStation/incomingCall");
          
       // msg.add(bg);
        oscP5.send(msg, myRemoteLocation);
        
      } else if (name.equals("VideoCallEnd")){
        OscMessage msg = new OscMessage("/clientscreen/CommsStation/hangUp");
        oscP5.send(msg, myRemoteLocation);
      }
      
    } catch (ClassCastException e){}
   
    try {
      Slider s = (Slider)theControlEvent.getController();
      OscMessage msg = new OscMessage("/display/captain/chromaparams");
      msg.add((int)chromaSlider.getValue()); //r
      msg.add((int)lowerSlider.getValue());  //g
      msg.add((int)upperSlider.getValue());  //b
      msg.add((int)thSlider.getValue());
      oscP5.send(msg, myRemoteLocation);
      
      
    } catch(ClassCastException e){
    }
    
     try {
      Knob b = (Knob)theControlEvent.getController();
     //  println((int)b.value());
      OscMessage msg = new OscMessage("/system/powerManagement/failureSpeed");
      
      msg.add((int)b.value());
      oscP5.send(msg, myRemoteLocation);
    }catch (ClassCastException e){}
   
    
  }
  
}
  
  
