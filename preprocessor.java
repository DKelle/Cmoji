import java.io.*;
import java.util.*;
import java.nio.file.*;
import java.nio.charset.*;

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
	ArrayList<String> outfile = new ArrayList<String>();
	boolean done = false;
	byte[] utf8Bytes;
	int varnum = 0;	

        while(!done){
            try {
                String inputStr;
                if((inputStr=bufReader.readLine()) != null) {
		    for(String emoji : inputStr.split(" "))
		    {
			if(!unicodeToKey.containsKey(escapeUnicode(emoji)))
			{
			    unicodeToKey.put(escapeUnicode(emoji), "var"+varnum);
			    varnum++;
			}
		        outfile.add(unicodeToKey.get(escapeUnicode(emoji)));
		    }
		    outfile.add("\n");
		}
                else {
		    done = true;
                }
            }
            catch (Exception e) {
	    	e.printStackTrace();
	    }
        }

	if(debug)
	{
	    for(String str : outfile)
	    {
		System.out.println(str);
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
	    for(String str: outfile) {
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

		unicodeToKey.put(escapeUnicode(lines[0]), lines[1]);
                //System.out.println(line);
            }

            bufferedReader.close();
        }
        catch(IOException e) {
            e.printStackTrace();
        }

    }

}
