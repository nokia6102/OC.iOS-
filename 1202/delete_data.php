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
    
    //============先檢查資料庫資料是否存在============
    $selectSQL = sprintf("select * from student where no=%d",$pkNo);
    //執行select指令
    $result=mysql_query($selectSQL) or die(mysql_error());
    if ($row_array=mysql_fetch_row($result))
    {
        //該筆資料存在
        $dataExist = 1;
    }
    else
    {
        //找不到該筆資料
        $dataExist = 0;
    }
    //===============實際刪除資料庫資料===============
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
    if ($dataExist == 1 && $result == 1)
    {
        //回傳執行成功
        echo "1";
    }
    else
    {
        //回傳執行失敗
        echo "0";
    }
?>