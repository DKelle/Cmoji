import java.io.*;
import java.util.*;
import java.nio.file.*;
import java.nio.charset.*;

public class preprocessor
{
    private HashMap<String, String> unicodeToKey;
    private boolean debug = true;

    public static void main(String[] args)
    {
	    new preprocessor();
    }

    public preprocessor()
    {
	    initHash();
        InputStreamReader isReader = new InputStreamReader(System.in);
        BufferedReader bufReader = new BufferedReader(isReader);
	    ArrayList<String> outfile = new ArrayList<String>();
	    boolean done = false;
	    byte[] utf8Bytes;
	    int varnum = 0;	
        String emoji = "";

        while(!done){
            try {
                String inputStr;
                if((inputStr=bufReader.readLine()) != null) 
                {
                    inputStr = inputStr.replaceAll("\\s+", "");
                    String escapedStr = escapeUnicode(inputStr);
                    int i = 0;
                    int substringLen = 5;
                    String numbers = "0123456789";
                    while(i < escapedStr.length() - 6)
                    {
                        //Each emoji is 2 sets of 5 chars long Ex: \\ud83d\\udda
                        //Except numbers, which has 6 chars, and then 5 chars Ex: 5\ufe0f\u20e3
 
                        //Build up the first part of the emoji (which may have the extra char)
                        if(numbers.contains(escapedStr.substring(i,i+1)))
                        {
                            emoji += escapedStr.substring(i,i+7);
                            i += 7;
                        }
                        else
                        {
                            emoji += escapedStr.substring(i,i+6);
                            i += 6;
                        }

                        //build up the second part of the emoji (which will never have the extra char)
                        emoji += escapedStr.substring(i,i+6);
                        i += 6;

                        if(!unicodeToKey.containsKey(escapeUnicode(emoji)))
                        {
                            unicodeToKey.put(escapeUnicode(emoji), "var"+varnum);
                            varnum++;
                        }
                        outfile.add(unicodeToKey.get(escapeUnicode(emoji)));
                        emoji = "";
                    }
                    outfile.add("\n");
                    
		        }
                else 
                {
		            done = true;
                }
            }
            catch (Exception e) 
            {
	    	    e.printStackTrace();
	        }
        }

	    createOutput(outfile);

    }

    public void createOutput(ArrayList<String> outfile)
    {
	    FileWriter writer = null;
	    try
	    {
	        writer = new FileWriter("preprocessed.txt"); 
	        for(String str: outfile)  
            {
 		        writer.write(str+" ");
	        }
	        writer.close();
	    }
	    catch(Exception e)
	    {
	        System.out.println("Could not create preprocessed.txt");
	        e.printStackTrace();
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

        try 
        {
            FileReader fileReader = new FileReader(fileName);
            BufferedReader bufferedReader = new BufferedReader(fileReader);

            while((line = bufferedReader.readLine()) != null) 
            {
		        line = line.replaceAll("\\s+", "");
		        String[] lines = line.split("//");
		        if(lines.length > 2)
		        {
		            System.out.println("ERROR: emoji unicode contains '//'");
		            System.exit(0);
		        }
		
		        unicodeToKey.put(escapeUnicode(lines[0]), lines[1]);
                //System.out.println(line);
            }

            bufferedReader.close();
        }
        catch(IOException e) 
        {
            e.printStackTrace();
        }
    }

}
