package main

import (
    "encoding/gob"
    "io/ioutil"
    "fmt"
//  "github.com/Baozisoftware/qrcode-terminal-go"
    "github.com/Rhymen/go-whatsapp"
//      "github.com/bradfitz/gomemcache/memcache"
//  "github.com/Rhymen/go-whatsapp/binary/proto"
    "encoding/json"
    "os"
    "github.com/skip2/go-qrcode"
    "strings"
    "time"
    "net/http"
    "flag"
    "bytes"
    "encoding/base64"
)

var TEMP_DIR = "/tmp/"
var APP_DIR = "/usr/local/webchat/"
var SOURCE_ID = "1"
var WEBCHAT_TOKEN = "d434f336-944e-4e66-93f4-ec061ec1c509"
var WEBCHAT_URL = "http://localhost:7000/api"


var WEBCHAT_URL_SAVE = WEBCHAT_URL+"/message/1/?token="+WEBCHAT_TOKEN
var WEBCHAT_URL_DOWNLOAD = WEBCHAT_URL+"/message/download/1/?token="+WEBCHAT_TOKEN
var WEBCHAT_URL_CONFIRM = WEBCHAT_URL+"/message/confirm/1/?token="+WEBCHAT_TOKEN
var WEBCHAT_URL_VALIDATE = WEBCHAT_URL+"/validate/?token="+WEBCHAT_TOKEN

type MessageType int32

const (
    TEXT   MessageType = 0
    AUDIO MessageType = 1
    IMAGE MessageType = 2
    DOCUMENT MessageType = 3
    VIDEO MessageType = 4
)

type MessageQueue struct{
    id string
    contact string
    fileurl string
    caption string 
    message string
    mimetype string
    thumbnail []byte
    fromMe bool
    messageType MessageType
}


type MessageRequest struct{
    Id int32  `json:"id"`
    Contact string `json:"contact"`
    Fileurl string `json:"fileurl"`
    Caption string `json:"caption"`
    Messagetxt string `json:"message"`
    Mimetype string `json:"mimetype"`
    Mtype string `json:"mtype"`
}

func validateApi()(string) {
    bodystr := []byte(`{"validate":"1"}`)
    req, err := http.NewRequest("POST", WEBCHAT_URL_VALIDATE,bytes.NewBuffer(bodystr))
    req.Header.Set("Content-Type", "application/json")    
    client := &http.Client{}
    resp, err := client.Do(req)
    resptxt, err := ioutil.ReadAll(resp.Body)
    if err != nil {
        panic(err)
    }
        
    fmt.Println(resptxt)
    defer resp.Body.Close()

    if resp.StatusCode != 201 {
        fmt.Println(string(resptxt))
        os.Exit(1)
    }
    
    return string(resptxt)
}

func getMessageQueue()([]MessageRequest, string){

    bodystr := []byte(`{"download":"1"}`)
    req, err := http.NewRequest("POST", WEBCHAT_URL_DOWNLOAD, bytes.NewBuffer(bodystr))
    req.Header.Set("Content-Type", "application/json")
    
    client := &http.Client{}
    resp, err := client.Do(req)
    if err != nil {
        panic(err)
    }
    responseJson, err := ioutil.ReadAll(resp.Body)
    var msgs []MessageRequest
    json.Unmarshal(responseJson, &msgs)

    if err != nil {
        panic(err)
    }
    //fmt.Println (msgs)
    defer resp.Body.Close()
    return msgs,""
}

func sendMessage(wac *whatsapp.Conn, msg MessageRequest)(int) {

    var status = 0

    if msg.Mtype == "chat" || msg.Mtype == "" {
        fmt.Println(msg)
        wmsg := whatsapp.TextMessage{
                Info: whatsapp.MessageInfo{
                        RemoteJid: msg.Contact,
                },
                Text: msg.Messagetxt,
        }

        msgId, err := wac.Send(wmsg)
        status = 2
        if err != nil {
                fmt.Fprintf(os.Stderr, "error sending message: %v", err)
                status = 99
        } else {
                fmt.Println("Message Sent -> ID : "+msgId)
        }
    }

    if msg.Mtype == "image" {
        fmt.Println(msg)
        img, err := os.Open(msg.Fileurl)
        if err != nil {
            fmt.Fprintf(os.Stderr, "error reading file: %v\n", err)
            status = 99
        }

        if err == nil {
            wmsg := whatsapp.ImageMessage{
                Info: whatsapp.MessageInfo{
                    RemoteJid: msg.Contact,
                },
                Type:    msg.Mimetype,
                Caption: "",
                Content: img,
            }

            msgId, err := wac.Send(wmsg)
            status = 2
            if err != nil {
                    fmt.Fprintf(os.Stderr, "error sending message: %v", err)
                    status = 99
            } else {
                fmt.Println("Message Sent -> ID : "+msgId)
        }
        }
    }


    if msg.Mtype == "audio" {
        
        audio, err := os.Open(msg.Fileurl)
        if err != nil {
            fmt.Fprintf(os.Stderr, "error reading file: %v\n", err)
            status = 99
        }

        if err == nil {
            wmsg := whatsapp.AudioMessage{
                Info: whatsapp.MessageInfo{
                    RemoteJid: msg.Contact,
                },
                Type:    msg.Mimetype,
                Content: audio,
            }

            msgId, err := wac.Send(wmsg)
            status = 2
            if err != nil {
                    fmt.Fprintf(os.Stderr, "error sending message: %v", err)
                    status = 99
            } else {
                fmt.Println("Message Sent -> ID : "+msgId)
            }
        }
    }

    if msg.Mtype == "video" {
        
        video, err := os.Open(msg.Fileurl)
        if err != nil {
            fmt.Fprintf(os.Stderr, "error reading file: %v\n", err)
            status = 99
        }
        if err == nil {
            wmsg := whatsapp.VideoMessage{
                Info: whatsapp.MessageInfo{
                    RemoteJid: msg.Contact,
                },
                Type:    msg.Mimetype,
                Content: video,
            }

            msgId, err := wac.Send(wmsg)
            status = 2
            if err != nil {
                    fmt.Fprintf(os.Stderr, "error sending message: %v", err)
                    status = 99
            } else {
                fmt.Println("Message Sent -> ID : "+msgId)
            }
        }
    }

    if msg.Mtype == "document" {
        
        document, err := os.Open(msg.Fileurl)
        if err != nil {
            fmt.Fprintf(os.Stderr, "error reading file: %v\n", err)
            status = 99
        }
        if err == nil { 
            wmsg := whatsapp.DocumentMessage{
                Info: whatsapp.MessageInfo{
                    RemoteJid: msg.Contact,
                },
                Type:    msg.Mimetype,
                Content: document,
            }

            msgId, err := wac.Send(wmsg)
            status = 2
            if err != nil {
                    fmt.Fprintf(os.Stderr, "error sending message: %v", err)
                    status = 99
            } else {
                fmt.Println("Message Sent -> ID : "+msgId)
            }
        }
    }   


    var jsondata = `
    {
        "messageid" : "%v",
        "status" : "%v"
    }
    `;

    jsondata = fmt.Sprintf(jsondata,msg.Id, status)
    body := []byte(jsondata)
    req, err := http.NewRequest("POST", WEBCHAT_URL_CONFIRM, bytes.NewBuffer(body))
    req.Header.Set("Content-Type", "application/json")
    
    client := &http.Client{}
    resp, err := client.Do(req)
    if err != nil {
        return -1
    }
    defer resp.Body.Close()
    return status



}
func saveMessage(wh* waHandler, msg MessageQueue) string {

    contactname  := wh.wac.Store.Contacts[msg.contact]
    
    var tjson = `
    {   "id" : "%v",
        "contact" : "%v",
        "contactname": "%v",
        "type" : %v,
        "caption": "%v",
        "message": "%v",
        "fromMe" : "%v"%v
    }
    `;

    var file = "";
    if msg.messageType != TEXT {
        file = fmt.Sprintf(`,
        "url" :"%v",
        "mimetype" : "%v"
        `, msg.fileurl, msg.mimetype);
    }  

    tjson = fmt.Sprintf(tjson, msg.id,msg.contact,contactname.Name,msg.messageType,msg.caption,msg.message,msg.fromMe,file)
    body := []byte(tjson)
    fmt.Println(tjson);
    req, err := http.NewRequest("POST", WEBCHAT_URL_SAVE, bytes.NewBuffer(body))
    req.Header.Set("Content-Type", "application/json")
    
    client := &http.Client{}
    resp, err := client.Do(req)
    if err != nil {
        fmt.Println(err)
        //panic(err)
    }
    if err == nil { 
        defer resp.Body.Close()
    }

    return fmt.Sprintf("%v\n%v",err,resp)
}

func notifyMessage(id int32, status int) string {

    var json = `
    {
        "messageid" : "%v",
        "status" : %v
    }
    `;

    json = fmt.Sprintf(json,id,status)
    body := []byte(json)
    req, err := http.NewRequest("POST", WEBCHAT_URL_CONFIRM, bytes.NewBuffer(body))
    req.Header.Set("Content-Type", "application/json")
    
    client := &http.Client{}
    resp, err := client.Do(req)
    if err != nil {
        fmt.Println(err)
        time.Sleep(10 * time.Second)
        return string(status)
    }
    defer resp.Body.Close()
    return string(status)

}



type waHandler struct {
    wac       *whatsapp.Conn
    startTime uint64
}

func (wh *waHandler) HandleError(err error) {
    fmt.Fprintf(os.Stderr, "error caught in handler: %v\n", err)
    err2 := os.Remove(APP_DIR + "media/qr"+SOURCE_ID+".png");
    if err2!= nil {
        fmt.Println(err2)
    }
    if strings.Contains(err.Error(), "server closed connection"){
        login(wh.wac)
    }
}


func (wh *waHandler) HandleImageMessage(message whatsapp.ImageMessage) {
    if message.Info.FromMe {
        return
    }
    var fid = message.Info.Source.GetKey().GetId()
    var mimetype = message.Info.Source.GetMessage().GetImageMessage().GetMimetype()
    var ext = strings.Split(mimetype, "/")[1]

    file,err := message.Download()
    if err == nil{
        f, err := os.Create(TEMP_DIR+fid+"."+ext)
        if err == nil{
            _, err := f.Write(file)
            if err == nil{
                f.Sync()
                mesg := MessageQueue{
                    id : message.Info.Id,
                    fileurl : TEMP_DIR+fid+"."+ext,
                    contact : message.Info.RemoteJid,
                    caption : message.Caption,
                    message : "",
                    fromMe :  message.Info.FromMe,
                    messageType : IMAGE,
                    mimetype : mimetype}
                saveMessage(wh,mesg)
            }
        } else {
            fmt.Println(err)
        }
        f.Close()
    }
}

func (wh* waHandler) HandleVideoMessage(message whatsapp.VideoMessage) {
    if message.Info.FromMe {
        return
    }
    var fid = message.Info.Source.GetKey().GetId()
    var mimetype = message.Info.Source.GetMessage().GetVideoMessage().GetMimetype()
    var ext = strings.Split(mimetype, "/")[1]

    file,err := message.Download()
    if err == nil{
        f, err := os.Create(TEMP_DIR+fid+"."+ext)
        if err == nil{
            _, err := f.Write(file)
            if err == nil{
                f.Sync()
                mesg := MessageQueue{
                    id : message.Info.Id,
                    fileurl : TEMP_DIR+fid+"."+ext,
                    contact : message.Info.RemoteJid,
                    caption : message.Caption,
                    message : "",
                    fromMe :  message.Info.FromMe,
                    messageType : VIDEO,
                    mimetype : mimetype}
                saveMessage(wh, mesg)
            }
        } else {
            fmt.Println(err)
        }
        f.Close()
    }

}


func (wh* waHandler) HandleAudioMessage(message whatsapp.AudioMessage) {
    if message.Info.FromMe {
        return
    }
    var fid = message.Info.Source.GetKey().GetId()
    var mimetype = message.Info.Source.GetMessage().GetAudioMessage().GetMimetype()
    var ext = strings.Split(mimetype, "/")[1]

    file,err := message.Download()
    if err == nil{
        f, err := os.Create(TEMP_DIR+fid+"."+ext)
        if err == nil{
            _, err := f.Write(file)
            if err == nil{
                f.Sync()
                mesg := MessageQueue{
                    id : message.Info.Id,
                    fileurl : TEMP_DIR+fid+"."+ext,
                    contact : message.Info.RemoteJid,
                    caption : "",
                    message : "",
                    fromMe :  message.Info.FromMe,
                    messageType : AUDIO,
                    mimetype : mimetype}
                saveMessage(wh, mesg)
            }
        }
        f.Close()
    }

}

func (wh* waHandler) HandleDocumentMessage(message whatsapp.DocumentMessage) {
    if message.Info.FromMe {
        return
    }
    var fid = message.Info.Source.GetKey().GetId()
    var mimetype = message.Info.Source.GetMessage().GetDocumentMessage().GetMimetype()
    var ext = strings.Split(mimetype, "/")[1]

    file,err := message.Download()
    if err == nil{
        f, err := os.Create(TEMP_DIR+fid+"."+ext)
        if err == nil{
            _, err := f.Write(file)
            if err == nil{
                f.Sync()
                mesg := MessageQueue{
                    id : message.Info.Id,
                    fileurl : TEMP_DIR+fid+"."+ext,
                    contact : message.Info.RemoteJid,
                    message : "",
                    fromMe :  message.Info.FromMe,
                    messageType : DOCUMENT,
                    mimetype : mimetype}
                saveMessage(wh, mesg)
            }
        } else {
            fmt.Println(err)
        }
        f.Close()
    }

}





func (wh* waHandler) HandleJsonMessage(message string) {
    fmt.Printf("'%v'", message)
}

//func (wh* waHandler) HandleRawMessage(message *proto.WebMessageInfo) {
//  fmt.Printf("raw:\n\n%v\n\n", message)
//}


func (wh *waHandler) HandleTextMessage(message whatsapp.TextMessage) {
    if message.Info.FromMe {
        return
    }
    mesg := MessageQueue{
        id: message.Info.Id,
        fileurl : "",
        contact : message.Info.RemoteJid,
        caption : "",
        messageType : TEXT,
        fromMe :  message.Info.FromMe,
        message : message.Text,
        mimetype : ""}

    saveMessage(wh, mesg)

}

func dologin(wac *whatsapp.Conn) error {
    qr := make(chan string)
//      mc := memcache.New("127.0.0.1:11211")

    go func() {
//      terminal := qrcodeTerminal.New()
//      terminal.Get(<-qr).Print()
//      b := []byte(<-qr)
//      mc.Set(&memcache.Item{Key: "qrcode", Value: b})

        err := qrcode.WriteFile(<-qr, qrcode.Medium, 256, APP_DIR + "media/qr"+SOURCE_ID+".png")
        if err == nil{
            fmt.Println("qr salvo em "+APP_DIR + "media/qr"+SOURCE_ID+".png")
        }

    }()

    session, err := wac.Login(qr)

    if err != nil {
        err2 := os.Remove(APP_DIR + "media/qr"+SOURCE_ID+".png");
        if err2!= nil {
           fmt.Println(err2)
        }

        return fmt.Errorf("error during login: %v", err)
    }

    if err = writeSession(session); err != nil {
        err2 := os.Remove(APP_DIR + "media/qr"+SOURCE_ID+".png");
        if err2!= nil {
           fmt.Println(err2)
        }

        return fmt.Errorf("error saving session: %v", err)
    }

    err2 := os.Remove(APP_DIR + "media/qr"+SOURCE_ID+".png");
    if err2!= nil {
       fmt.Println(err2)
    }

//  mc.Delete("qrcode")
    return nil
}

func login(wac *whatsapp.Conn) error {
    session, err := readSession()
    if err == nil {
        session, err = wac.RestoreWithSession(session)
        return err
    } else {
        err := dologin(wac)
        return err
    }

}




func readSession() (whatsapp.Session, error) {
    session := whatsapp.Session{}

    file, err := os.Open(APP_DIR+"sessions/"+SOURCE_ID+".gob")
    if err != nil {
        return session, err
    }
    defer file.Close()

    decoder := gob.NewDecoder(file)
    if err = decoder.Decode(&session); err != nil {
        return session, err
    }

    return session, nil
}

func writeSession(session whatsapp.Session) error {
    file, err := os.Create(APP_DIR+"sessions/"+SOURCE_ID+".gob")
    if err != nil {
        return err
    }
    defer file.Close()

    encoder := gob.NewEncoder(file)
    if err = encoder.Encode(session); err != nil {
        return err
    }

    return nil
}

func FileExists(name string) (bool, error) {
  _, err := os.Stat(name)
  if os.IsNotExist(err) {
    return false, nil
  }
  return err != nil, err
}

var relog = false
func main() {

    fmt.Println("Init WhatsApp Client")

    dataf := flag.String("data", "","\tInstance Data")
    flag.Parse()

    if *dataf == ""{
        panic("Inicialização de forma inválida")
    }

    //fmt.Println(*dataf)

    dataBytes, err := base64.StdEncoding.DecodeString(*dataf)

    var dataString = string(dataBytes)
    var data = strings.Split(dataString, ",")

    fmt.Println(data)
    APP_DIR = data[0]
    SOURCE_ID = data[1]
    WEBCHAT_TOKEN = data[2]
    WEBCHAT_URL = data[3]
    WEBCHAT_URL_SAVE = WEBCHAT_URL+"/message/"+SOURCE_ID+"/?token="+WEBCHAT_TOKEN
    WEBCHAT_URL_DOWNLOAD = WEBCHAT_URL+"/message/download/"+SOURCE_ID+"/?token="+WEBCHAT_TOKEN
    WEBCHAT_URL_CONFIRM = WEBCHAT_URL+"/message/confirm/"+SOURCE_ID+"/?token="+WEBCHAT_TOKEN
    WEBCHAT_URL_VALIDATE = WEBCHAT_URL+"/validate/?token="+WEBCHAT_TOKEN
    fmt.Println(WEBCHAT_URL_SAVE)

    go func(){
            for {
                fmt.Println("Validate Webchat")
                validateApi()
                time.Sleep(120 * time.Minute)
                
            }
    }()

    fmt.Println("New Connection")
    wac, err := whatsapp.NewConn(5 * time.Second)

    if err != nil {
        fmt.Fprintf(os.Stderr, "error creating connection: %v\n", err)
        return
    }

    wac.AddHandler(&waHandler{wac, uint64(time.Now().Unix())})

    fmt.Println("Login")
    if err := login(wac); err != nil {
        fmt.Fprintf(os.Stderr, "error logging in: %v\n", err)
        return 
    }

    go func(){
            for true{
                time.Sleep(2 * time.Second)
                msgs, err := getMessageQueue()
                if err == ""{
                    for i := range msgs {
                        status := sendMessage(wac,msgs[i])
                        if status != -1{
                            notifyMessage(msgs[i].Id,status)
                        }
                    }
                }
            }
            
        }()

    <-time.After(60 * time.Minute)

}


