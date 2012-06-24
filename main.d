module main;

import std.stdio;
import hangmangame;
import colord;

void main()
{
	auto pendu = new HangmanGame("dico.txt");
	scope(exit) clear(pendu);
	try
	{
		pendu.run();
	}
	catch(Exception e)
	{
		writefln("Exception : %s", e.msg);
	}
	finally
	{
		setConsoleForeground(Color.Default);
	}
	setConsoleForeground(Color.Default);
}
