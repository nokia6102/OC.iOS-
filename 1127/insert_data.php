<?PHP
    //指定網頁的中文格式
    header("Content-type: text/html; charset=utf-8");
    //連接資料庫
    //mysql_connect("IP","帳號","密碼");
    mysql_connect("mysql.2freehosting.com","u829095379_perki","mimi2003");
    //指定資料庫
    mysql_query("use u829095379_mydb");
    //指定資料庫使用的編碼
    mysql_query("SET NAMES utf8");
    
    //準備update指令
    //insert into student(no,name,gender,picture,phone,address,email,class) values(222,'測試',1,'images/222.jpg','091234343','地址','xyz@email.com','手機程式設計')
    $insertSQL = sprintf("insert into student(no,name,gender,picture,phone,address,email,class) values(%d,'%s',%d,'%s','%s','%s','%s','%s')",$_GET['no'],$_GET['name'],$_GET['gender'],$_GET['picture'],$_GET['phone'],$_GET['address'],$_GET['email'],$_GET['class']);
    //執行update指令
    $result=mysql_query($insertSQL) or die(mysql_error());
    //回傳執行狀態
    echo $result;
?>