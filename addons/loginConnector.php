<?php
  $path = './wp-includes';
  $path_admin= './';
  set_include_path(get_include_path() . PATH_SEPARATOR . $path . PATH_SEPARATOR .$path_admin);
  require('./wp-load.php');

  $msg_reject = 'Unauthorized access! No key specified';

#  $_GET['key'] = trim( file_get_contents('connector.props') );
#  $_GET['func'] = 'authenticate';
#  $_GET['login'] = 'mtuck@codefire.com.au';
#  $_GET['pword'] = 'mtuck';

  //Simple authentication
  if(isset($_GET['key'])){

    $authKey = trim( file_get_contents('connector.props') );

    if($_GET['key'] != $authKey){
      exit( $msg_reject );
    }
  }
  else{
    exit ($msg_reject);
  }

 $con = new Connector();
  if(isset($_GET['login'])){
    $con->addUserData('user_login',$_GET['login']);
  }

  if(isset($_GET['pword'])){
    $con->addUserData('user_pass',$_GET['pword']);
  }

  if(isset($_GET['email'])){
    $con->addUserData('user_email',$_GET['email']);
  }

  if(isset($_GET['firstname'])){
    $con->addUserMetaData('first_name',$_GET['firstname']);
  }

  if(isset($_GET['lastname'])){
    $con->addUserMetaData('last_name',$_GET['lastname']);
  }

  if(isset($_GET['premium'])){
    if($_GET['premium']=='true'){
      $con->addUserMetaData('premium',true);
    }
    else{
      $con->addUserMetaData('premium',false);
    }
  }
  
  switch($_GET['func']) {
    case 'create':
      $user = $con->create();
      echo $user?$user:-1;
      break;
    case 'exists':
      $user = $con->exists();      
      echo $user?$user:-1 ;
      break;
    case 'update':
      $user = $con->update();
      echo $user?$user:-1;   
      break;
    case 'authenticate':
      $auth = $con->Authenticate();
      echo $auth?$auth:-1; //$auth;
      break;      
    default:
      echo 'Function not Found';
  }

class Connector{

  private $data = array();
  private $meta = array();

  /**
   * Connector class constructor
   */
  function __construct() {
  }


  /**
   * Adds user data
   *
   * @param string $key data identifier
   * @param string $value data value
   */
  function addUserData($key, $value){   
    $this->data[$key] = $value;
  }

  /**
   * Adds user meta data
   *
   * @param string $key meta data identifier
   * @param string $value meta data value
   */
  function addUserMetaData($key, $value){
    $this->meta[$key] = $value;
  }

  /**
   * Check to see if user profile exists in wordpress
   *
   *
   * @return string user_login on success, null on failure
   */
  function exists(){
    global $wpdb;
    
    if(array_key_exists('user_login', $this->data)){
      $user = get_userdatabylogin( $this->data['user_login'] );
    }
    elseif(array_key_exists('user_email', $this->data)){
      $user = get_user_by_email($this->data['user_email']);
    }

    if(!$user){
      return false;
    }
    else{
      return $user->user_login;
    }
  }


  /**
    * Creates a new user profile in wordpress.
    *
    * @return string user_login on success, null on failure
    */
  function create(){
    global $wpdb;

    if(!$this->exists())
{
   
   //Validate user data for create
      if( !( array_key_exists('user_login', $this->data) && array_key_exists('user_pass', $this->data) && array_key_exists('user_email', $this->data) ) ){
        return false; 
      }


      // Hash the password
      $this->data['user_pass'] = wp_hash_password($this->data['user_pass']);

      $this->data['user_login'] = sanitize_user($this->data['user_login'], true);
      $this->data['user_login'] = apply_filters('pre_user_login', $this->data['user_login']);

      $this->data['user_email'] = apply_filters('pre_user_email', $this->data['user_email']);
      
      $this->data['user_registered'] = gmdate('Y-m-d H:i:s');
      //$this->data['user_nicename'] = $this->data['user_login'];
      //$this->data['display_name'] = $this->data['user_login'];

      $this->data['user_nicename'] = $this->meta['first_name'] . " " . $this->meta['last_name'];
      $this->data['display_name'] = $this->meta['first_name'] . " " . $this->meta['last_name'];

      $this->data = stripslashes_deep( $this->data );
 
      $wpdb->insert( $wpdb->users, $this->data);
      $user_id = (int) $wpdb->insert_id;

      //Add user meta data
      foreach($this->meta as $meta_key => $meta_value){
        $wpdb->insert($wpdb->usermeta, compact('user_id', 'meta_key', 'meta_value') );
      }
    //  update_usermeta( $user_id, 'first_name', $this->meta['first_name']);
    //  update_usermeta( $user_id, 'last_name', $this->meta['last_name']);


      $user = new WP_User($user_id);
      $user->set_role('subscriber');

      wp_cache_delete($user_id, 'users');
      wp_cache_delete($this->data['user_login'], 'userlogins');

      do_action('user_register', $user_id);

      if( !$user ){
        return false;//'user not created';
      }
      else{
        if(!array_key_exists('premium', $this->meta) || !$this->meta['premium']){
          //First delete any entries for this users email address
          $result = $wpdb->query( $wpdb->prepare("DELETE FROM cmanager_users WHERE Email = %s", $this->data['user_email']) ); 
          
          //Insert the new user record.
          $result = $wpdb->query( $wpdb->prepare( "INSERT INTO cmanager_users (ContactId, ContactListId, ContactList, FirstName, LastName, Email, ContactStatus, SubStatus  ) VALUES(%s,%s,%s,%s,%s,%s,%d,%d)", array($this->data['user_login'],'b6745460-d848-4f7c-8dd8-425a5ee6e66b','Free/Contra - standard',$this->meta['first_name'], $this->meta['last_name'], $this->data['user_email'],1,0)));
        } 
        return  $user->user_login;
      }
    }
    else{
      return false; //'User already exists';
    }  
  }

  /**
   * Updates a user profile in wordpress
   *
   * @return string user_login on success, null on failure
   */
  function Update(){
    global $wpdb;  
 
    if(array_key_exists('user_login', $this->data)){
      $user = get_userdatabylogin( $this->data['user_login'] );
    }

    if(!$user){
      return false;//'User does not exists!';
    }
    else{
     // if(!array_key_exists('premium', $this->meta) || !$this->meta['premium']){       
       
     //   $wpdb->query( "DELETE FROM cmanager_users WHERE ContactID ='" . $this->data['user_login'] . "'"); 

     // }
 


	
      if(array_key_exists('user_pass', $this->data)){
        $this->data['user_pass'] = wp_hash_password($this->data['user_pass']);
      }
      
      $result = $wpdb->update( $wpdb->users, $this->data, array('ID' => $user->ID) );
  
      //Update user meta data
      foreach($this->meta as $meta_key => $meta_value){
        update_usermeta( $user->ID, $meta_key, $meta_value);
      }

      if( !$user ){
        return false;//'';
      }
      else{
        $query = "SELECT COUNT(1) FROM cmanager_users WHERE ContactID ='" . $this->data['user_login'] . "'"; 

        $user_count = $wpdb->get_var($wpdb->prepare($query));

        if($user_count == 0){
          $result = $wpdb->query( $wpdb->prepare( "INSERT INTO cmanager_users (ContactId, ContactListId, ContactList, FirstName, LastName, 
Email, ContactStatus, SubStatus  ) VALUES(%s,%s,%s,%s,%s,%s,%d,%d)", array($this->data['user_login'],'b6745460-d848-4f7c-8dd8-425a5ee6e66b'
,'Free/Contra - standard',$this->meta['first_name'], $this->meta['last_name'], $this->data['user_email'],1,0)));
        }
        else{
          $query = 'UPDATE cmanager_users SET ';

          $sets = array();
          if(array_key_exists('user_email', $this->data)){
            array_push($sets, "user_email = '" . $this->data['user_email'] . "'");
          }    

          if(array_key_exists('first_name', $this->meta)){
            array_push( $sets , "first_name = '" . $this->meta['first_name'] . "'");
          }

          if(array_key_exists('last_name', $this->meta)){
            array_push($sets, " last_name = '" . $this->meta['last_name'] . "'");
          }

          $wpdb->query($query . " " . join(",",$sets));
        } 
        return $user->user_login;
      }
    }
  }

  /*
   * Authenticates the users based on the passed credentials
   *
   *
   * @return boolean true on success, false on failure
   */
   function Authenticate(){
     global $wpdb;

require_once( './wp-includes/class-phpass.php');

     if(array_key_exists('user_login', $this->data)){
       $user = get_userdatabylogin( $this->data['user_login'] );
     }
     elseif(array_key_exists('user_email', $this->data)){
       $user = get_user_by_email($this->data['user_email']);
     }
    
     $wp_hasher = new PasswordHash(8, true);
     $password_hashed = $user->user_pass; // '$P$B55D6LjfHDkINU5wF.v2BuuzO0/XPk/';
     $plain_password = $this->data['user_pass']; // 'test';


     if($wp_hasher->CheckPassword($plain_password, $password_hashed)) {
       return $user->user_login; //echo "Yes, Matched!"; 
     }
     else {
       return false;  //echo "No, Wrong Password";
     }


     return true;

  }
}//End class connector

?>
