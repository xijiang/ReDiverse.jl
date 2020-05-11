#include <iostream>
using namespace std;

int main(int argc, char *argv[])
{
  // s: snp;  c: chr;  b: bp
  string sa, sb;
  int ca, cb, ba, bb;
  ca = ba = 0;
  while(cin>>sb>>cb>>bb){
    if(ca == cb && ba == bb) cout<<sa<<' '<<sb<<'\n';
    sa = sb;
    ca = cb;
    ba = bb;
  }
  return 0;
}
