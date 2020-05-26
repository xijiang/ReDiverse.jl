/**
 * This is to split a final report with many ID stacked vertically and sharing one header.
 * Each splitted file will have the `ID name`.txt as the file name.
 * Usage:
 *     cat the-final-report | this-program shortlist-dict
 */
#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <map>

using namespace std;

int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false);
  map<string, string> sdc;	// shortlist dictionary GenofileId -> GenoId
  {
    ifstream fin(argv[1]);
    for(string a, b; fin>>a>>b; sdc[a] = b);
  }
  
  ofstream foo;
  vector<string> header;
  string ID, line;
  bool   output{false};
  while(getline(cin, line)){
    header.push_back(line);
    if(line.substr(0, 8) == "SNP Name") break;
  }
  while(getline(cin, line)){
    stringstream ss(line);
    string snp, id;
    ss>>snp>>id;
    if(id != ID){
      ID = id;
      foo.close();
      output = false;
      clog << "\rID "<< id;
      if(sdc.find(id) != sdc.end()){
	output = true;
	foo.open(sdc[id] + ".txt");
	for(const auto&l:header) foo<<l<<'\n';
	clog <<" -> "<<sdc[id]<<"                    "<<flush;
      }else clog << " is skipped.     "<<flush;
    }
    if(output){
      stringstream ss(line);
      string snp, id, rest;
      ss>>snp>>id;
      getline(ss, rest);
      foo<<snp<<'\t'<<sdc[id]<<rest<<'\n';
    }
  }
  foo.close();

  clog << '\n';
  return 0;
}
