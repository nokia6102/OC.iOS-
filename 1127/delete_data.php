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
    
    //讀取要刪除資料的primary key
    $pkNo = $_GET['no'];

    //============實際刪除資料庫資料============
    //準備delete指令
    $deleteSQL = sprintf("delete from student where no=%d",$pkNo);
    //執行delete指令
    $result=mysql_query($deleteSQL) or die(mysql_error());
    
    if ($result == 1)
    {
        //刪除伺服器上對應學號的上傳檔案
        @unlink('images/' . $pkNo .'.jpg');
    }
    
    //回傳執行狀態
    echo $result;
?>