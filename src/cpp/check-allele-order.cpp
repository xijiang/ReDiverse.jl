#include <iostream>
#include <map>
#include <sstream>

/*
Descriptoin:

If the alternative alleles are in different order across different platforms,
this program will print the SNP appeared in the latter platform(s).

File sample:
1	Hapmap43437-BTA-101873	0	135098	G	A
1	ARS-BFGL-NGS-16466	0	267940	A	G
*/
using namespace std;

int main(int argc, char *argv[])
{
  int chr, d, bp;
  string snp;
  char a, b;
  map<string, char> ref;
  while(cin>>chr>>snp>>d>>bp>>a>>b){
    if(ref.find(snp)==ref.end()) ref[snp] = a;
    else if(ref[snp] != a) cout<<snp<<endl;
  }
  return 0;
}
