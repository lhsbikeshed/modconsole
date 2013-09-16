/* controls for the dead scene */


/* ADD A BUTTON TO CANCEL SD, as itwill need to trigger "all ok" message and turn off the infection thing */
public class NebulaControls extends PanelSet {

  String[] bangList = { 
    "Lightning\r\nStrike", "Blow Up Gate", "start\r\ndistress\r\nsignal", 
    "Reposition\r\nVan", "Spawn\r\nAnomaly"
  };
  String[] bangMapping = {
    "/scene/nebula/spawnLightning", "/scene/nebula/blowUpGate", "/scene/nebula/startPuzzle", 
    "/scene/nebula/repositionVan", "/scene/nebula/spawnAnomaly"
  };
  /* toggle buttons and their osc messages */
  String[] toggleList = { 
    "dummy"
  };
  String[] toggleMapping = {
    "/dummy"
  };



  public NebulaControls(String name, PApplet parent, OscP5 p5, ControlP5 cp5) {
    super(name, parent, p5, cp5);


                              
     cp5.addNumberbox("Disk1")
     .setPosition(780,120)
     .setSize(100,14)
     .setScrollSensitivity(0.1)
     .setValue(3)
     .setMax(20)
     .setMin(1)
     .moveTo(name)   
     ;
     cp5.addNumberbox("Disk2")
     .setPosition(780,150)
     .setSize(100,14)
     .setScrollSensitivity(0.1)
     .setValue(11)
     .setMax(20)
     .setMin(1)
     .moveTo(name)   
     ;
     cp5.addNumberbox("Disk3")
     .setPosition(780,180)
     .setSize(100,14)
     .setScrollSensitivity(0.1)
     .setValue(6)
     .setMax(20)
     .setMin(1)
     .moveTo(name)   
     ;
     cp5.addBang("SetDisks")
     .setPosition(780, 220)
     .setSize(50, 20)
     .setTriggerEvent(Bang.RELEASE)
     .setLabel("Set Disks")
     .moveTo(name)        
     ;
     
  }

  public void draw() {
  }

  public void initGui() {

    //bang list
    for (int i = 0; i < bangList.length; i++) {
      cp5.addBang(bangList[i])
        .setPosition(140 + i * 75, 250)
          .setSize(50, 50)
            .setTriggerEvent(Bang.RELEASE)
              .setLabel(bangList[i])  
                .moveTo(name)   
                  ;
    }
    for (int i = 0; i < toggleList.length; i++) {
      // system toggles
      cp5.addToggle(toggleList[i])
        .setPosition(140 + i * 75, 340)
          .setSize(50, 20)
            .moveTo(name)
              ;
    }
  }

  public void oscMessage(OscMessage msg) {
  }
  public void controlEvent(ControlEvent theControlEvent) {
    String name = theControlEvent.getName();

    /* do the toggle list first */
    try {
      Toggle t = (Toggle)theControlEvent.getController();

      for (int i = 0; i < toggleList.length; i++) {
        if (toggleList[i].equals(name)) {
          //get the state of the toggle
          int state = (int)theControlEvent.getValue();
          OscMessage msg = new OscMessage(toggleMapping[i]);

          msg.add(state);
          oscP5.send(msg, myRemoteLocation);
        }
      }
    } 
    catch (ClassCastException e) {
    }

    /* do the bang list first */
    try {
      Bang t = (Bang)theControlEvent.getController();

      for (int i = 0; i < bangList.length; i++) {
        if (bangList[i].equals(name)) {
          //get the state of the toggle

            OscMessage msg = new OscMessage(bangMapping[i]);
          oscP5.send(msg, myRemoteLocation);
        }
      }
      
      if(name.equals("SetDisks")){
        
        //transmit the disk numbers for engineering
        OscMessage msg = new OscMessage("/system/boot/diskNumbers");
        msg.add( (int)(cp5.get(Numberbox.class,"Disk1").getValue()) );
        msg.add( (int)(cp5.get(Numberbox.class,"Disk2").getValue()) );
        msg.add( (int)(cp5.get(Numberbox.class,"Disk3").getValue()) );
        oscP5.send(msg, myRemoteLocation);
        
      }
    } 
    catch (ClassCastException e) {
    }

    try {
      Knob b = (Knob)theControlEvent.getController();
      
     
    }
    catch (ClassCastException e) {
    }
  }
}

