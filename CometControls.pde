/* controls for the drop scene */

public class CometControls extends PanelSet {
  
  
  String[] bangList = { "FixCables", "AuthCode", "escape scene", "fire at\r\n player"};
  int[]    bangValue = { 0, 0, 3, 1};
  String[] bangMapping = {"/system/cablePuzzle/cancelPuzzle", "/system/authsystem/codeOk", "/scene/CometScene/escape", "/scene/CometScene/bastard"};
  
  
  boolean panelRepaired = false;
  boolean codeOk = false;
  
  public CometControls(String name, PApplet parent, OscP5 p5, ControlP5 cp5){
    super(name, parent, p5, cp5);
  }
  
  public void reset(){
   
  }
  
  public void draw(){
    
    textFont(font, 15);
    
    
    
  }
  
  
  public void initGui(){
    
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
