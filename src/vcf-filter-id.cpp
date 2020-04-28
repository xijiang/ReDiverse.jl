#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>

using namespace std;

int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false);
  
  int thresh(stoi(argv[1]));
  ifstream fin(argv[2]);
  vector<bool> keep;
  
  for(int x; fin>>x;)
    if(x>=thresh) keep.push_back(true);
    else          keep.push_back(false);

  for(string line; getline(cin, line);)
    if(line[1] == '#') cout<<line<<'\n';
    else{
      stringstream ss(line);
      string f;
      ss>>f;
      cout<<f;
      for(auto i{1}; i<9; ++i){
	ss>>f;
	cout<<'\t'<<f;
      }
      for(const auto&x:keep){
	ss>>f;
	if(x) cout<<'\t'<<f;
      }
      cout<<'\n';
    }
  return 0;
}
