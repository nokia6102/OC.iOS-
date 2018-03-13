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
    
    //存取資料表
    //SELECT no, name, gender, picture, phone, address, email, class FROM student
    $table = mysql_query("SELECT no, name, gender, picture, phone, address, email, class FROM student order by no");
    
    //宣告記錄xml資料的變數
    $doc = new DOMDocument('1.0', 'utf-8');
    $doc->formatOutput = true;
    //建立根節點
    $xmlTable = $doc->appendChild($doc->createElement('xmlTable'));
    
    while ($row_array=mysql_fetch_row($table))
    {
        //echo $row_array[0] . ',' . $row_array[1] . '<br>';
        //一筆資料的開頭
        $row = $doc->createElement('student');
        //------------依序欄位的節點--------------
        //第0欄:no
        $column = $row->appendChild($doc->createElement('no'));
        $column->appendChild($doc->createTextNode($row_array[0]));
        //第1欄:name
        $column = $row->appendChild($doc->createElement('name'));
        $column->appendChild($doc->createTextNode($row_array[1]));
        //第2欄:gender
        $column = $row->appendChild($doc->createElement('gender'));
        $column->appendChild($doc->createTextNode($row_array[2]));
        //第3欄:picture
        $column = $row->appendChild($doc->createElement('picture'));
        $column->appendChild($doc->createTextNode($row_array[3]));
        //第4欄:phone
        $column = $row->appendChild($doc->createElement('phone'));
        $column->appendChild($doc->createTextNode($row_array[4]));
        //第5欄:address
        $column = $row->appendChild($doc->createElement('address'));
        $column->appendChild($doc->createTextNode($row_array[5]));
        //第6欄:email
        $column = $row->appendChild($doc->createElement('email'));
        $column->appendChild($doc->createTextNode($row_array[6]));
        //第7欄:class
        $column = $row->appendChild($doc->createElement('class'));
        $column->appendChild($doc->createTextNode($row_array[7]));
        
        $xmlTable->appendChild($row);
    }
    //將$doc寫成xml格式的文件
    $xmlStr = $doc->saveXML();
    //顯示整份xml文件
    echo $xmlStr;
?>
