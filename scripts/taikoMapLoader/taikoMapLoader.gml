// Skriptelemente wurden für v2.3.0 geändert, weitere Informationen sind unter
// https://help.yoyogames.com/hc/en-us/articles/360005277377 verfügbar

function loadTaikoMap(){ // Opens a tja file for reading
globalvar MAP_FILE_NAME;
globalvar MAP_FILE_ID;


MAP_FILE_NAME = get_open_filename("taiko file|*.tja","");
if(MAP_FILE_NAME != "")
{
	MAP_FILE_ID=file_text_open_read(MAP_FILE_NAME);
	return true;
}
return false;
}

function calcCellLen(__lower)
{
	var __cellLen;
	__cellLen = (CELL_COEFFICIENT*(4/__lower));
	return __cellLen;
}

function calcRowLen(__upper, __cellLen)
{
	return __upper*__cellLen
}

function calcNoteDist(__cellLen, __rowNoteCount, __upper)
{
	return __cellLen/(__rowNoteCount/__upper);
}

function readTaikoMap() // Reads contents of the tja file opened
{
// Read from the tja file
globalvar TJA_ARRAY;
TJA_ARRAY = array_create(1)
var i = 0;

// Transfer contents to the TJA ARRAY
while(!file_text_eof(MAP_FILE_ID))
{
	// Increase array size
	if(array_length(TJA_ARRAY) > i)
	{
		temparr = array_create(i+1)
		array_copy(temparr,0,TJA_ARRAY,0,i+1)
	}
	
	
    TJA_ARRAY[i] = file_text_read_string(MAP_FILE_ID);
    file_text_readln(MAP_FILE_ID);
	i++;
}

// Debug: Print map
for(i = 0; i<array_length(TJA_ARRAY);i++)
{
	show_debug_message(string(i) + " : "+string(TJA_ARRAY[i]))
}

}

function getTaikoCommand(linestr)
{
	/*
	0 = Normal taiko data
	1 = START
	2 = BPMCHANGE
	3 = MEASURE
	*/
	//show_debug_message(linestr)
	var llen = string_length(linestr); // get string length
	
	/*
	if(string_replace_all(linestr,",","") == linestr)
	{
		show_debug_message(string_replace_all(linestr,",","")+"||"+string(linestr))
		return -1;
	}*/
	
	
	if(llen == 6 && string_copy(linestr,2,5) == "START") // Start command?
	{
		return 1;
	}
	
	if(llen >= 10 && string_copy(linestr,2,9) == "BPMCHANGE")
	{
		return 2;
	}
	
	if(llen >= 8 && string_copy(linestr,2,7) == "MEASURE")
	{
		return 3;
	}
	
	return 0;
	
	
}

function handleTaikoCmd(linestr, command)
{
	switch(command)
	{
		case 0: // Data
		var arg = linestr+"OWOW"
		return arg;
		break;
		
		case 1: // Start
		return "-1";
		break;
		
		case 2: // #BPMCHANGE (args)
		var arg = string_replace(linestr, "#BPMCHANGE ","");
		return arg;
		break;		
		
		case 3: // #MEASURE (args)
		var arg = string_replace(linestr, "#MEASURE ","");
		//show_debug_message(arg)
		return arg; // Will return sth like "2/4"
		
		break;		
		
	}
}

function interpretTaikoMap()
{
var rowCount = 1;	
var currUpper = 0;
var currLower = 0;
// Loop through the whole TJA Array storing the contents of the TJA file

show_debug_message("TJA ARRAY....")
for(var i = 0; i<array_length(TJA_ARRAY)-1; i++)
{
var line;
line = TJA_ARRAY[i];

// Get if current line is raw data or a command
	
	if(string_char_at(line,0) == "#")
	{
		// it is a command
		var cmd = getTaikoCommand(line); // get the cmd
		var cmdarg = handleTaikoCmd(line,cmd); // get the args
		
		switch(cmd)
		{
		
			
			case 1: // START
			if(rowCount == 0)
			{
				rowCount ++;
			}
			show_debug_message("--> START: "+cmdarg);
			
			break;
			
			case 2: // BPMCHANGE
			show_debug_message("--> BPMCHANGE: "+cmdarg);
			var inst = instance_create_depth(CURRENT_SPAWNX,y-16,1,obj_note);
			inst.text = "BPM: "+string(cmdarg);
			break;
			
			case 3: // MEASURE
			
			{
			// Get the components
			var _len = string_length(cmdarg);
			var _upper = "";
			var _lower = "";
			show_debug_message("Line 151: Cmdarg: "+cmdarg + "|| len: "+string(_len))
			
			var _iterator = 1;
			var slashfound = false;
			while(_iterator < _len+1)
			{
				if(string_char_at(cmdarg,_iterator) == "/")
				{
					// Do stuff
					slashfound = true;
					_iterator ++;
				}
				else
				{
					/// Assign values
					switch(slashfound)
					{
						case false:
						_upper = _upper + string_char_at(cmdarg,_iterator);
						break;
						
						case true:
						_lower = _lower + string_char_at(cmdarg,_iterator);
						break;
					}					
					_iterator ++;
				}
			}
			
			
			currLower = _lower;
			currUpper = _upper;
			
			show_debug_message("--> MEASURE: "+currUpper+"/"+currLower)
			break;
			}
			
		}
	}
	else // its not a command#region Data
	{
		// Is it data?
		if(string_char_at(line,string_length(line)) == ",")
		{
			// create  row note
			var inst = instance_create_depth(CURRENT_SPAWNX,y,1,obj_note);
			inst.text = string(rowCount);
			
			// Data row
			var rawNotes = string_replace_all(line,",","");
			var noteCount = string_length(rawNotes);
			//show_message_async(rawNotes)
			var cellLen = calcCellLen(currLower)*SPAWN_MULTIPLIER;
			//var rowLen = calcRowLen(currUpper,cellLen)*SPAWN_MULTIPLIER;
			var noteDist = calcNoteDist(cellLen,noteCount,currUpper)*SPAWN_MULTIPLIER;
			// Iterate
			for(var n = 0; n < noteCount; n++)
			{
				switch(string_char_at(rawNotes,n+1))
				{
					case "1": // Don
					instance_create_depth(CURRENT_SPAWNX,y,0,obj_noteRedSmall);		
					break;
					
					case "2": // Ka
					instance_create_depth(CURRENT_SPAWNX,y,0,obj_noteBlueSmall);		
					break;
					
					case "3": // Big Don
					var inst = instance_create_depth(CURRENT_SPAWNX,y,0,obj_noteRedSmall);
					with(inst)
					{
						image_xscale = image_xscale*1.5
						image_yscale = image_yscale*1.5
					}
					break;
					
					case "4": // Big Ka
					var inst = instance_create_depth(CURRENT_SPAWNX,y,0,obj_noteBlueSmall);
					with(inst)
					{
						image_xscale = image_xscale*1.5
						image_yscale = image_yscale*1.5
					}
					break;
				}
				
				CURRENT_SPAWNX = CURRENT_SPAWNX+noteDist
				
			}
			
			rowCount += 1;			
		}
	
		// Is it title?
		if(string_copy(line,1,5) == "TITLE")
		{
			SONG_NAME = string_replace(line,"TITLE: ","");
		}
	}
	

}


}


