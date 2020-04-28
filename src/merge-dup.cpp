#include <iostream>
#include <sstream>
#include <map>
#include <fstream>
#include <vector>

using namespace std;
// Usage: cat some.vcf | path/merge-dup dup.snp >merged.vcf
int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false);

  ifstream fin(argv[1]);
  map<string, string> dic;
  for(string a, b; fin>>a>>b;){
    dic[a] = b;
    dic[b] = b;			// meaning I will only keep the names in the 2nd column
  }
  
  int pchr{0}, pbp{0};
  string pln;	   // previous line, chr and bp, and pre-previous line
  vector<string> buffer;

  for(string line; getline(cin, line);)
    if(line[0] == '#'){
      cout<<line<<'\n';		// just copy the header
    }else{
      buffer.push_back(line);
      int chr, bp;
      string snp;
      stringstream ss(line);
      ss >> chr >> bp >> snp;
      if((chr == pchr) && (bp == pbp)){
	buffer.pop_back();
	stringstream tt(pln), rr;
	string a, b;
	rr << chr << '\t' << bp << '\t' <<dic[snp];
	for(auto i=0; i<6; ++i){
	  ss>>a;
	  rr << '\t' << a;
	}
	for(auto i=0; i<9; ++i) tt >> a;
	while(ss>>a){
	  tt>>b;
	  if(a[0] == '.') rr << '\t' << b;
	  else            rr << '\t' << a;
	}
	for(auto&s:buffer) cout << s <<'\n';
	buffer.clear();
      }
      pchr = chr;
      pbp = bp;
      pln = line;
    }
  for(auto&s:buffer) cout << s <<'\n';
  buffer.clear();
  
  return 0;
}
