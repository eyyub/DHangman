module utils;

/+ Eponymous trick, si un identificateur a le m�me nom que le template, il est invoqu� � sa place
 + �a �vite un : isChar!C.isChar dans un constraint                                            +/
 
template isChar(C)
{
	enum bool isChar = is(C == char) || is(C == dchar) || is(C == wchar);  
}

/+ out signifie que le param�tre est une r�f�rence vers l'objet/la variable mais qu'elle est r�inisialis�e
 + � son �tat de base.
 + if(isChar!C) est un template constraint permettant de checker certaines conditions d'invocation d'une
 + fonction template at compile-time, dans ce cas si, si le type C n'est pas un char/dchar/wchar alors
 + il y a une erreur � la compilation signifiant qu'il n'y a aucune fonction readc sp�cialis�e pour le
 + type C.                                                                                                 +/
 
C readc(C)(out C letter) if(isChar!C)
{
	import std.cstream;
	letter = din.getc();
	din.flush();
	
	return letter;
}

// cache un mot
char[] hide(char[] word, char symbol)
{
	char[] hideWord;
	for(int i = 0; i < word.length; ++i)
	{
		hideWord ~= symbol;
	}
	return hideWord;
}