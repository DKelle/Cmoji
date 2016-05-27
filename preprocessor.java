import java.io.*;
import java.util.*;


public class preprocessor
{
    private HashMap<String, String> unicodeToKey;
    private boolean debug = false;

    public static void main(String[] args)
    {
	new preprocessor();
    }

    public preprocessor()
    {
	initHash();
        InputStreamReader isReader = new InputStreamReader(System.in);
        BufferedReader bufReader = new BufferedReader(isReader);
	boolean done = false;
	byte[] utf8Bytes;
	
        while(!done){
            try {
                String inputStr;
                if((inputStr=bufReader.readLine()) != null) {

		    if(debug)
		    {
                    	System.out.print("the string I read was: ");
		    	System.out.println(inputStr);
		    	System.out.println(escapeUnicode(inputStr));	
		    	System.out.println("Translates to " + unicodeToKey.get(inputStr));
		    }
		    
		}
                else {
		    done = true;
                }
            }
            catch (Exception e) {
	    	e.printStackTrace();
	    }
        }
    }

    public String escapeUnicode(String input)
    {
        StringBuilder b = new StringBuilder(input.length());
        Formatter f = new Formatter(b);
        for (char c : input.toCharArray())
        {
            if (c < 128)
            {
                b.append(c);
            }
            else
            {
                f.format("\\u%04x", (int) c);
            }
        }
        return b.toString();
    }

    public void initHash()
    {
	unicodeToKey = new HashMap<String, String>();

        String fileName = "initmap.txt";
        String line = null;

        try {
            FileReader fileReader = new FileReader(fileName);
            BufferedReader bufferedReader = new BufferedReader(fileReader);

            while((line = bufferedReader.readLine()) != null) {
		String[] lines = line.split("//");
		if(lines.length > 2)
		{
		    System.out.println("ERROR: emoji unicode contains '//'");
		    System.exit(0);
		}
		
		if(debug) for(String s : lines) System.out.println(s);

		unicodeToKey.put(lines[0], lines[1]);
                //System.out.println(line);
            }

            bufferedReader.close();
        }
        catch(IOException e) {
            e.printStackTrace();
        }

    }

}
