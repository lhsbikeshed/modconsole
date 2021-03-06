/* controls for the drop scene */

public class DropControls extends PanelSet {
  
  float altitude = 0;
  float[] temps = new float[6];
  String[] tempNames = {"Top Temp", "Bottom Temp", "Left Temp", "Right Temp", "Front Temp", "Back Temp"};
  
  String[] bangList = { "RepairPanel", "AuthCode"};
  int[]    bangValue = { 1, 2};
  String[] bangMapping = {"/scene/drop/droppanelrepaired", "/scene/drop/droppanelrepaired"};
  
  
  boolean panelRepaired = false;
  boolean codeOk = false;
  
  public DropControls(String name, PApplet parent, OscP5 p5, ControlP5 cp5){
    super(name, parent, p5, cp5);
  }
  
  public void reset(){
    altitude = 0;
    temps = new float[6];
    panelRepaired = false;
    codeOk = false;
  }
  
  public void draw(){
    
    textFont(font, 15);
    
    for(int i = 0; i < 6; i++){
      if(temps[i] < 200){
        fill(0,255,0);
      } else if (temps[i] >=200 && temps[i] <= 250){
        fill(255,255,0);
      } else {
        fill(255,0,0);
      }
      text(tempNames[i] + " : " + temps[i], 60,230 + i * 15);
    }
    
    fill(255,255,255);
    
    text("Altitude : " + altitude, 60,330);
    if(panelRepaired){
      text("Broken panel repaired, waiting for code", 60,345);
    } else {
      text("Waiting for panel repair", 60,345);
    }
    if(codeOk){
      text("CODE OK! Jump enabled", 60,360);
    } else {
      text("Waiting for code....", 60,360);
    }
    
  }
  
  
  public void initGui(){
    cp5.addTextlabel(name+"label")
      .setText("SCRIPT ----------------\r\n1. Warn the pilot that the ship cant reenter atmosphere and needs to be rotated to keep temp under 300\r\n2. 'assess the damage' and let them know the jump system power is out\r\n3.Inform tact/eng to look at consoles and repair ship\r\n4. once repaired give them the emergency jump code and get them out")
      .setPosition(12,50)
      .setColorValue(0xffffff00)
      .setFont(createFont("Georgia",15))
      .moveTo(name)
      ;
  //bang list
     for (int i = 0; i < bangList.length; i++){
       cp5.addBang(bangList[i])
         .setPosition(440 + i * 75, 300)
         .setSize(50, 50)
         .setTriggerEvent(Bang.RELEASE)
         .setLabel(bangList[i])  
         .moveTo(name)
  
         ;
     }
  
  }
  
  public void oscMessage(OscMessage msg){
  
  
    if (msg.checkAddrPattern("/scene/drop/statupdate")==true) {
      altitude = msg.get(0).floatValue();
      for (int t = 0; t < 6; t++) {
        temps[t] = msg.get(1+t).floatValue();
      }
    } else if (msg.checkAddrPattern("/scene/drop/droppanelrepaired")==true) {
      int dat = msg.get(0).intValue();
      if(dat == 1){
        panelRepaired = true;
      } else if (dat == 2){
        codeOk = true;
      }
    }
  
  
  }
  
  public void controlEvent(ControlEvent theControlEvent) {
  /* do the bang list first */
      String name = theControlEvent.getName();

    try {
      Bang t = (Bang)theControlEvent.getController();
      
      for(int i = 0; i < bangList.length; i++){
        if(bangList[i].equals(name)){          
          OscMessage msg = new OscMessage(bangMapping[i]);
          msg.add(bangValue[i]);
          oscP5.send(msg, myRemoteLocation);
            
        }      
      } 
      
      
      
    } catch (ClassCastException e){}
  
  
  }
  
}
