module hangmangame;

import std.stdio;
import std.string;
import std.format : formattedRead, format;
import std.cstream;
import std.conv : to;
import std.random: uniform;
import std.exception : enforce;
import std.ascii : isDigit, isASCII, toUpper;
import colord;
import utils;

final class HangmanGame
{
	private
	{
		Hangman _hangman;
		string[] _dict;
		char[] word;
		char[] secretWord;
	}
	private
	{
		class Hangman
		{
			private
			{
				uint _currentLife;
				uint _currentAnim;
				uint _life;
				string[] _anim;
			}
			public
			{
				this(string filename)
				{
					auto animfile = std.stdio.File(filename, "r");
					scope(exit) animfile.close();
					_currentAnim = 0;
					foreach(line; animfile.byLine())
					{
						if(line.startsWith("Life"))
						{
							formattedRead(line, "Life %s", &_life);
							break;
						}				
					}
					foreach(line; animfile.byLine())
					{
						if(line.startsWith("anim"))
						{
							_anim.length++;
							continue;
						}
						_anim[$-1] ~= line ~ '\n';
					}
					enforce(_life == _anim.length, format("This file(%s) is not valid : Life and anim's length are not the same", filename));
					_currentLife = _life;
				}	
				string currentAnim() const
				{
					return (_currentAnim < _anim.length) ? _anim[_currentAnim] : _anim[$-1];
				}
				@property uint life() const
				{
					return _currentLife;
				}
				void looseLife()
				{
					_currentLife--;
					_currentAnim++;
				}
				void respawn()
				{
					_currentLife = _life;
				}
			}
		}
		string[] makeDict(string filename)
		{
			auto file = std.stdio.File(filename, "r");
			string[] dict;
			foreach(line; file.byLine())
			{
				dict ~= to!string(line);
			}
			return dict;
		}
		void menu()
		{
			char choice;
			auto difficult = std.stdio.File("difficult.txt", "r");
			scope(exit) difficult.close();
			char[] easy, medium, hard;
			foreach(line; difficult.byLine())
			{
				if(line.startsWith("Hard"))
					formattedRead(line, "Hard %s", &hard);
				else if(line.startsWith("Medium"))
					formattedRead(line, "Medium %s", &medium);
				else if(line.startsWith("Easy"))
					formattedRead(line, "Easy %s", &easy);
				else
					throw new StdioException("This file(difficult.txt) is not valid");
			}
			
			setConsoleForeground(Color.Red);
			writeln("###################################################################");
			writeln("#   Welcome in Hangman game !                                     #");
			writeln("# Rules :                                                         #");
			writeln("#        - A French word is taken at random.                      #");
			writeln("#        - This word is hiden.                                    #");
			writeln("#        - The purpose is to find the letters which composes it.  #");
			writeln("#        - You have limited chances.                              #");
			writeln("###################################################################\n");
			setConsoleForeground(Color.Default); // white
			
			setConsoleForeground(Color.Green);
			writeln("   Difficult :           ");
			writeln("              1 - Hard   ");
			writeln("              2 - Medium ");
			writeln("              3 - Easy   ");
			write  ("   Please select one : ");
			do
			{
				setConsoleForeground(Color.Yellow);
				readc(choice);
				switch(choice)
				{
					case '1' :
						_hangman = new Hangman(hard.idup);
						break;
					case '2' :
						_hangman = new Hangman(medium.idup);
						break;
					case '3' :
						_hangman = new Hangman(easy.idup);
						break;
					default:
						setConsoleForeground(Color.Blue);
						write("Wrong answer, try again : ");
						break;
				}
				debug(log) writeln("---", choice, "---");
			}while(choice != '1' && choice != '2' && choice != '3');
			setConsoleForeground(Color.Default);
		}
		void game()
		{		
			char letter;
			setConsoleForeground(Color.Red);
			writeln(_hangman.currentAnim());
			writefln("Chances : %d", _hangman.life);
			setConsoleForeground(Color.Purple);
			foreach(secretLetter; secretWord)
			{
				writef("%s ", secretLetter);
			}
			write("\n");
			
			do
			{
				setConsoleForeground(Color.Green);
				write("\nChoose one letter please : ");
				setConsoleForeground(Color.Yellow);
				readc(letter);

			}while(isDigit(letter) || !isASCII(letter) || letter == '\n');
			
			letter = to!char(toUpper(letter));
			
			if(count(word, letter) > 0 && count(secretWord, letter) == 0)
			{
				foreach(i, l; word)
				{
					if(letter == l)
						secretWord[i] = letter;
				}
				setConsoleForeground(Color.Azure);
				writeln("\nGreat answer !");
			}
			else if(count(secretWord, letter) > 0)
			{
				setConsoleForeground(Color.Azure);
				writeln("\nYou already gave this good answer.");
			}
			else
			{
				setConsoleForeground(Color.Azure);
				writeln("\nWrong answer.\n");
				_hangman.looseLife();
				setConsoleForeground(Color.Default);
			}
		}
		
	}
	public
	{
		this(string dictFilename)
		{
			_dict = makeDict(dictFilename);
		}
		void run()
		{
			bool playing = true;
			bool endgame = false;
			bool win = false;
			char choice;		
			do
			{
				word = _dict[uniform(0, _dict.length)].dup;
				secretWord = hide(word, '_');	
				menu();
				do
				{	
					game();	
					if(secretWord == word)
						endgame = true;
					else if(_hangman.life == 0)
						endgame = true;	
				}while(!endgame);
				
				setConsoleForeground(Color.Aqua);
				writefln("The word was : %s", word);
				
				do
				{
					setConsoleForeground(Color.Green);
					writeln("\nDo you want to try again ?\n");
					writeln("Y for Yes.");
					writeln("N for No.\n");
					write("Answer : ");
					setConsoleForeground(Color.Yellow);
					readc(choice);
					choice = to!char(toUpper(choice));
				}while(choice != 'Y' && choice != 'N');
				
				if(choice == 'Y')
				{
					playing = true;
					endgame = false;
					_hangman.respawn();
				}
				else if(choice == 'N')
					playing = false;
				setConsoleForeground(Color.Default);
			}while(playing);
			
		}
		~this()
		{
			clear(_dict);
			clear(_hangman);
		}
	}
}