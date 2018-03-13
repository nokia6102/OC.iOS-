<?php
    header("Content-type: text/html; charset=utf-8");
    $conn=mysql_connect("mysql.2freehosting.com","u829095379_perki","mimi2003");
    mysql_query("use u829095379_mydb");
    mysql_query("SET NAMES utf8");
    
    //自訂解碼Unicode的方法：傳入JSon格式，將其中的Unicode資料解碼回正常的中文字
    function decodeUnicode($str)
    {
        return preg_replace_callback('/\\\\u([0-9a-f]{4})/i',
                 create_function('$matches','return mb_convert_encoding(pack("H*",$matches[1]),"UTF-8","UCS-2BE");'),
                                     $str);
    }

    $table=mysql_query("select no,name,gender,picture,phone,address,email,class from student order by no");
//    //儲存每一行資料的陣列
//    $row = array();
    
    while ($row_array=mysql_fetch_assoc($table))
    {
//        //逐一針對中文欄位進行unicode編碼
//        $row_array[1] = urlencode($row_array[1]);
//        $row_array[5] = urlencode($row_array[5]);
//        $row_array[7] = urlencode($row_array[7]);
        //將編碼過後的目前資料行(陣列型態)，存入新的資料集陣列
        $rows[] = $row_array;
    }
    //關閉資料庫連結
    mysql_close($conn);
    //將資料集陣列進行json編碼
    echo decodeUnicode(json_encode($rows));
?>