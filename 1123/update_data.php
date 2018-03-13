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
    
    //update student set name='testname',gender=0,phone='123455',address='這裡',email='xyz@jj.kk',class='手機程式開發'  where no=101
    //http://perkinsung.2fh.co/update_data.php?name=測試&gender=1&phone=096699999&address=住址&email=xyz@kkk&class=網頁程式設計&no=101
//    echo $_GET['name'];
//    echo $_GET['gender'];
//    echo $_GET['phone'];
//    echo $_GET['address'];
//    echo $_GET['email'];
//    echo $_GET['class'];
//    echo $_GET['no'];
    //準備update指令
    $updateSQL = sprintf("update student set name='%s',gender=%d,phone='%s',address='%s',email='%s',class='%s' where no=%d",$_GET['name'],$_GET['gender'],$_GET['phone'],$_GET['address'],$_GET['email'],$_GET['class'],$_GET['no']);
    //執行update指令
    $result=mysql_query($updateSQL) or die(mysql_error());
    //回傳執行狀態
    echo $result;
?>