/* controls for the launch scene */

public class LaunchControl extends PanelSet {

  boolean gravOn = true;
  boolean clampOn = true;
  boolean grabberState = false;

  public LaunchControl(String name, PApplet parent, OscP5 p5, ControlP5 cp5) {
    super(name, parent, p5, cp5);
  }

  public void draw() {
    textFont(font, 12);
    text("docking grabber can be used? : " + grabberState, 100, 200);
  }


  public void initGui() {
    cp5.addTextlabel("label")
      .setText("SCRIPT ----------------\r\n1. captain tells the crew to start ship up and open blast door\r\n2. once started hit the 'start launch sequence' button, this puts them in the launch tube\r\n3. turn off gravity and release the clamp\r\n4. open the bay doors\r\n5.Autopilot the ship out of the base and park outside the door\r\n6.Wait for captain to ask for training missiles then turn them on\r\n7.When the training is done hit 'target gate'\r\nJOB DONE!")


        .setPosition(12, 50)
          .setColorValue(0xffffff00)
            .setFont(createFont("Georgia", 15))
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

    cp5.addBang("LaunchOtherShip")
      .setPosition(200, 230)
        .setSize(50, 50)
          .setLabel("Prepare/launch\r\nother ship")
            .setValue(1.0f)
              .moveTo(name)
                ;
    cp5.addBang("otherShipToGate")
      .setPosition(280, 230)
        .setSize(50, 50)
          .setLabel("Fly other\r\nship to gate")
            .setValue(1.0f)
              .moveTo(name)
                ;
    cp5.addBang("otherShipHyperspace")
      .setPosition(360, 230)
        .setSize(50, 50)
          .setLabel("npc Hyperspace")
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

    /* player names */
    cp5.addTextfield("PilotName")
      .setPosition(680, 135)
        .setSize(200, 30)
          .setFont(createFont("arial", 12))
            .setAutoClear(false)
              .moveTo(name)
                ;
    cp5.addTextfield("TacticalName")
      .setPosition(680, 195)
        .setSize(200, 30)
          .setFont(createFont("arial", 12))
            .setAutoClear(false)
              .moveTo(name)
                ;
    cp5.addTextfield("EngineerName")
      .setPosition(680, 255)
        .setSize(200, 30)
          .setFont(createFont("arial", 12))
            .setAutoClear(false)
              .moveTo(name)
                ;

    cp5.addBang("SetNames")
      .setPosition(681, 302)
        .setSize(50, 50)
          .setTriggerEvent(Bang.RELEASE)
            .setLabel("Set")
              .moveTo(name)
                ;
  }

  public void oscMessage(OscMessage msg) {

    if (msg.checkAddrPattern("/scene/launchland/grabberState") == true) {
      grabberState = msg.get(0).intValue() == 1 ? true : false;
    }
  }
  public void controlEvent(ControlEvent theControlEvent) {
    if (theControlEvent.getName().equals("BayDoors")) {
      // /scene/dockingBay 1
      OscMessage m  = new OscMessage("/scene/launchland/dockingBay");
      m.add(1);
      oscP5.send(m, myRemoteLocation);
    } 
    else if (theControlEvent.getName().equals("Bay Gravity")) {
      OscMessage m  = new OscMessage("/scene/launchland/bayGravity");
      m.add( (int)theControlEvent.getValue() );
      oscP5.send(m, myRemoteLocation);
    } 
    else if (theControlEvent.getName().equals("StartLaunch")) {
      OscMessage m  = new OscMessage("/scene/launchland/startLaunch");
      oscP5.send(m, myRemoteLocation);
    } 
    else if (theControlEvent.getName().equals("DockingClamp")) {
      OscMessage m  = new OscMessage("/system/misc/dockingClamp");
      m.add( (int)theControlEvent.getValue() );
      oscP5.send(m, myRemoteLocation);
    } 
    else if (theControlEvent.getName().equals("SpawnMissile")) {
      OscMessage m  = new OscMessage("/scene/launchland/trainingMissiles");
      m.add( (int)theControlEvent.getValue() );
      oscP5.send(m, myRemoteLocation);
    } 
    else if (theControlEvent.getName().equals("HighlightGate")) {
      OscMessage m  = new OscMessage("/scene/launchland/targetGate");
      m.add( (int)theControlEvent.getValue() );
      oscP5.send(m, myRemoteLocation);
    } 
    else if (theControlEvent.getName().equals("LaunchOtherShip")) {

      OscMessage m  = new OscMessage("/scene/launchland/launchOtherShip");

      oscP5.send(m, myRemoteLocation);
    } 
    else if (theControlEvent.getName().equals("otherShipToGate")) {

      OscMessage m  = new OscMessage("/scene/launchland/otherShipToGate");

      oscP5.send(m, myRemoteLocation);
    } 
    else if (theControlEvent.getName().equals("otherShipHyperspace")) {

      OscMessage m  = new OscMessage("/scene/launchland/otherShipHyperspace");

      oscP5.send(m, myRemoteLocation);
    } 
    else if (theControlEvent.getName().equals("SetNames")) {
      OscMessage m = new OscMessage("/game/params/setNames");
      m.add(cp5.get(Textfield.class, "PilotName").getText());
      m.add(cp5.get(Textfield.class, "TacticalName").getText());

      m.add(cp5.get(Textfield.class, "EngineerName").getText());
      oscP5.send(m, myRemoteLocation);
    }
  }
}

