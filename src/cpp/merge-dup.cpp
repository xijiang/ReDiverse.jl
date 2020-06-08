#include <iostream>
#include <sstream>
#include <map>
#include <fstream>

using namespace std;
// Usage: cat some.vcf | path/merge-dup dup.snp >merged.vcf
int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false);

  ifstream fin(argv[1]);
  map<string, string> dic;
  for(string a, b; fin>>a>>b;){
    dic[a] = a;
    dic[b] = a;	// meaning I will only keep the names in the 1st column
  }
  
  for(string line; getline(cin, line);)
    if(line[0] == '#'){
      cout<<line<<'\n';		// just copy the header
    }else{
      stringstream ss(line);
      int chr, bp;
      string snp;
      ss >> chr >> bp >> snp;	// peek into the first 3 fields
      if(dic.find(snp) != dic.end()){
	string next, SNP;
	int CHR, BP;
	getline(cin, next);	// no worry no next. not a case here.
	stringstream tt(next);
	tt >> CHR >> BP >> SNP;	// peek into the next line
	if(chr == CHR && bp == BP){ // and i know there is maximally one dup.
	  cout << chr << '\t' << bp << '\t' << dic[snp];
	  while(ss>>snp){	// merge the rest, elimit missing if possible
	    tt>>SNP;
	    if(snp[0] == '.') cout<<'\t'<<SNP;
	    else cout<<'\t'<<snp;
	  }
	  cout<<'\n';
	}else{ // a SNP duplicated elsewhere, not here, change snp name only
	  getline(ss, line);
	  cout << chr << '\t' << bp <<'\t' << dic[snp]<<line<<'\n';
	  cout << next <<'\n';
	}
      }else cout<<line<<'\n';
    }
  
  return 0;
}
