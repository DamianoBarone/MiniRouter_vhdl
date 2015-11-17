#include <iostream>
#include <fstream>
using namespace std;
//input sono req1,req2,data1,data2,reset
//output sono valid, data_out, grant1, grant2,;
unsigned char req1=0;
unsigned char req2=0;
unsigned short  int data1=0;
unsigned short int data2=0;
unsigned int grant1=0;
unsigned int grant2=0;
unsigned int valid=0;
unsigned char rr=0;
unsigned short int data_out=0;
string cestino;
ofstream desoutput;
void stampa()
{
	desoutput <<"valid: "<< valid ;
	desoutput<<" data_out: " << data_out;
	desoutput<<" grant1: " <<grant1;
	desoutput <<" grant2: "<< grant2<<"\n" ;
}
void assegna0()
{  
	stampa();			//pausa
	grant1=0;
	valid=0;
	grant2=0;

}
void assegna1()
{ 
	stampa();
	data_out=data1 & 0x00FF ; //cut bit priorities and connect data1 to output 
	grant1=1;				//update the bit of handshake
	valid=1;
	grant2=0;
}
void assegna2()
{ 
	stampa(); 
	data_out=data2 & 0X00FF; //cut bit priorities and connect data2 to output 
	grant2=1;			//update the bit of handshake
	valid=1;
	grant1=0;
}
int main ()
{

	ifstream desinput1("input1.txt");	//open files
	ifstream desinput2("input2.txt");
	desoutput.open("output.txt");
	stampa();
	for (int i=0; i<27;i++)
	{
		desinput1>>req1;		//read request1
		desinput2>>req2;		//read request2
		desinput1>>data1;		//read data1
		desinput2>>data2;		//read data2
		desinput1>>cestino;		//read a comment
		desinput2>>cestino;		//read a comment
	if (((req1=='1') && !grant1)&&(req2=='1' && !grant2)) // two request
	{
		if (data1>>8 > data2>>8) //link1 have priority
				assegna1();
		else
		{
			if (data1>>8 == data2>>8) //same priority 
				{
					if (rr==0)
					{
						assegna1(); //turn of link1
						rr=1;		//update varible of round robin
					}
					else	//turn of link2
					{
						assegna2();
						rr=0; //update varible of round robin
					}
				}
			else
				assegna2();
		}
	}
	else
	{
		if ((req1=='1')&& !grant1) //only request of link1
			assegna1();
		else 
		{
			if((req2=='1') && !grant2) //only request of link2
				assegna2();
			else
				assegna0();				//pause, has not  valid request
		}
	}
}
desinput1.close();			//close files
desinput2.close();
desoutput.close();
}
