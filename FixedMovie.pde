public class FixedMovie extends Movie {
  
  public FixedMovie(PApplet parent, String fname){
    super(parent, fname);
  }
  
  public boolean isPlaying(){
    return playing;
  }
}
