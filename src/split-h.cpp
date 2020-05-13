/**
 * This is to split a final report with many ID stacked vertically and sharing one header.
 * Each splitted file will have the `ID name`.txt as the file name.
 * Usage:
 *     cat the-final-report | this-program
 */
#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>

using namespace std;

int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false);
  ofstream foo;
  vector<string> header;
  string ID, line;
  while(getline(cin, line)){
    header.push_back(line);
    if(line.substr(0, 8) == "SNP Name") break;
  }
  while(getline(cin, line)){
    stringstream ss(line);
    string snp, id;
    ss>>snp>>id;
    if(id != ID){
      foo.close();
      foo.open(id+".txt");
      for(const string&l:header) foo<<l<<'\n';
      ID = id;
    }
    foo << line <<'\n';
  }
  return 0;
}
