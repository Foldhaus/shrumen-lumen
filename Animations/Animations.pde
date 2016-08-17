 /*
 * Demonstrate how to drive high frame rates using turbo_mode.
 *
 * Won't do anything until a PixelPusher is detected.
 */

import com.heroicrobot.dropbit.registry.*;
import com.heroicrobot.dropbit.devices.pixelpusher.Pixel;
import com.heroicrobot.dropbit.devices.pixelpusher.Strip;
import java.util.*;

DeviceRegistry registry;

class TestObserver implements Observer {
  public boolean hasStrips = false;
  public void update(Observable registry, Object updatedDevice) {
        //println("Registry changed!");
        if (updatedDevice != null) {
          //println("Device change: " + updatedDevice);
        }
        this.hasStrips = true;
    }
}

TestObserver testObserver;

// Global Animation State
String state = "default";

void getState() {
 String animationState = "default";
 
 try {
    // Hit API for state data
    String lines[] = loadStrings("http://localhost:3000/state");
    
    if(lines.length > 0){
      println("Got data from server.");
      // Parse Data from server
      JSONObject json = parseJSONObject(lines[0]);
      
      // Get the String representing the state
      String state = json.getString("state");
      
      // Resturn the state value
      animationState = state;
    }
    
  } catch(Exception e){
     println("Unable to reach server.");
  }
 
  state = animationState;
}

Default df;
Green gr;

final int CAP_STRIP_LENGTH = 60;
final int STEMP_STRIP_LENGTH = 240;

final List<Integer> STEM_STRIPS = Arrays.asList(6, 7); 

void setup() {
  registry = new DeviceRegistry();
  testObserver = new TestObserver();
  registry.addObserver(testObserver);
  colorMode(RGB, 255);
  size(128, 12);
  frameRate(100);
  
  df = new Default();
  gr = new Green();
}

void draw() {
  int x=0;
  int y=0;
  if (testObserver.hasStrips) {
        registry.setFrameLimit(1000);   
        registry.startPushing();
        registry.setExtraDelay(10);
        registry.setAutoThrottle(false);    
       
        int stripy = 0;
        List<Strip> strips = registry.getStrips();
        int numStrips = strips.size();
        //println("Strips total = "+numStrips);
        if (numStrips == 0)
          return;
        
        // Every 1000 frames request new data 
        if(frameCount % 500 == 0){
          thread("getState");  
        }
        
        // Determine which state the animations should
        // be in.
        println("STATE: " + state);
        switch(state) {
          case "test":
            // Run test script
            gr.display();
            break;
          default:
            // Run default script
            df.display();
            break;
            
        }
        
        //Apply the color value to the pixels in the strips
        int yscale = height / (strips.size() - STEM_STRIPS.size());
        for(Strip strip : strips) {
          //Check if the strip is a stem strip or a cap strip
          if(!STEM_STRIPS.contains(strip.getStripNumber())) { 
            int xscale = width / CAP_STRIP_LENGTH;
            for (int stripx = 0; stripx < strip.getLength(); stripx++) {
                x = stripx*xscale + 1;
                y = stripy*yscale + 1; 
                color c = get(x, y);
                 
                strip.setPixel(c, stripx);
             }
            stripy++;
          }
          else {
            //Set all the stem pixels to white
            for (int i = 0; i < strip.getLength(); i++) {
              color c = color(255, 255, 255);
              strip.setPixel(c, i);            
            }
          }
        }

      }
}