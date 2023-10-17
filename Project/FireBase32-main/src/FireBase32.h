#ifndef FireBase32_h
#define FireBase32_h

#include <WiFi.h>
#include <FirebaseESP32.h>
#include <Arduino.h>


class FireBase32{
  private:
    char* dbURL;
    char* apiKey;
    FirebaseData fbdata;
    FirebaseJson json;

    //  FirebaseData fbdataInt;
    //  FirebaseData fbdataChar;
    //  FirebaseData fbdataString;
    //  FirebaseData fbdataBool;
    //  FirebaseData fbdataDouble;
    //  FirebaseData fbdataFloat;
  public:

    FireBase32(char* URL, char* Key);
    void wifi(char* ssid, char* password);
    void WriteString(String info, char* path);
    void WriteData(int info, char* path);
    void WriteData(float info, char* path);
    void WriteData(bool info, char* path);
    void WriteData(FirebaseJson info, char* path);
    void GetString(char* path, String *dbData);
    void GetData(char* path, bool *dbData);
    void GetData(char* path, int *dbData);
    void GetData(char* path, float *dbData);

};


#endif
