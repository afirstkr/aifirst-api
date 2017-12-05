`use strict`

let initGlobal = ()=> {
  global.RCODE = {
    INVALID_PERMISSION      : `INVALID_PERMISSION`,
    INVALID_PARAMS          : `INVALID_PARAMS`,
    INVALID_MOBILE_INFO     : `INVALID_MOBILE_INFO`,
    INVALID_PARAMS_VALUES   : `INVALID_PARAMS_VALUES`,
    INVALID_LOGIN_INFO      : `INVALID_LOGIN_INFO`,
    INVALID_USER_INFO       : `INVALID_USER_INFO`,
    INVALID_PROCESS_ID      : `INVALID_PROCESS_ID`,
    INVALID_CONSTRUCTION_ID : `INVALID_CONSTRUCTION_ID`,
    INVALID_WORK_ID         : `INVALID_WORK_ID`,
    INVALID_ORDER_ID        : `INVALID_ORDER_ID`,
    INVALID_USER_ID         : `INVALID_USER_ID`,
    INVALID_MANAGER_ID      : `INVALID_MANAGER_ID`,
    INVALID_USER_CLASS      : `INVALID_USER_CLASS`,
    USER_RESIGNED           : `USER_RESIGNED`,
    PARAMS_REQUIRED         : `PARAMS_REQUIRED`,
    LOGIN_REQUIRED          : `LOGIN_REQUIRED`,
    USER_CONFIRM_REQUIRED   : `USER_CONFIRM_REQUIRED`,
    FILENAME_REQUIRED       : `FILENAME_REQUIRED`,
    IMAGE_REQUIRED          : `IMAGE_REQUIRED`,
    OLD_PASSWORD_REQUIRED   : `OLD_PASSWORD_REQUIRED`,
    SERVER_ERROR            : `SERVER_ERROR`,
    CHANNEL_ID_EXISTS       : `CHANNEL_ID_EXISTS`,
    USERNAME_EXISTS         : `USERNAME_EXISTS`,
    LOGIN_SUCCEED           : `LOGIN_SUCCEED`,
    LOGIN_FAILED            : `LOGIN_FAILED`,
    SIGNUP_SUCCEED          : `SIGNUP_SUCCEED`,
    LOGOUT_SUCCEED          : `LOGOUT_SUCCEED`,
    READ_SUCCEED            : `READ_SUCCEED`,
    CREATE_SUCCEED          : `CREATE_SUCCEED`,
    UPDATE_SUCCEED          : `UPDATE_SUCCEED`,
    UPLOAD_SUCCEED          : `UPLOAD_SUCCEED`,
    DELETE_SUCCEED          : `DELETE_SUCCEED`,
    OPERATION_SUCCEED       : `OPERATION_SUCCEED`,
    OPERATION_FAILED        : `OPERATION_FAILED`,
    USER_STATE_UPDATED      : `USER_STATE_UPDATED`,
    NO_RESULT               : `NO_RESULT`,
    USER_NOT_FOUND          : `USER_NOT_FOUND`,
    PROCESS_NAME_EXISTS     : `PROCESS_NAME_EXISTS`,
    COMPANY_NOT_FOUND       : `COMPANY_NOT_FOUND`,
    INVALID_REQUEST         : `INVALID_REQUEST`,
    INVALID_TOKEN           : `INVALID_TOKEN`,
    TOKEN_EXPIRED           : `TOKEN_EXPIRED`,
    OTP_EXPIRED             : `OTP_EXPIRED`,
    TOKEN_SAVED             : `TOKEN_SAVED`,
    INVALID_LEADER_ID       : `INVALID_LEADER_ID`,
    INVALID_CLASS           : `INVALID_CLASS`,
    INVALID_OTP_CODE        : `INVALID_OTP_CODE`,
    LEADER_ALREADY_ASSIGNED : `LEADER_ALREADY_ASSIGNED`,
    INVALID_MEMBER_ID       : `INVALID_MEMBER_ID`,
    EMAIL_REQUEST_SUCCEED   : `EMAIL_REQUEST_SUCCEED`,
    EMAIL_REQUEST_FAILED    : `EMAIL_REQUEST_FAILED`,
    EMAIL_AUTH_SUCCESS      : `EMAIL_AUTH_SUCCEED`,
    EMAIL_AUTH_FAILED       : `EMAIL_AUTH_FAILED`,
    SMS_REQUEST_SUCCEED     : `SMS_REQUEST_SUCCEED`,
    SMS_REQUEST_FAILED      : `SMS_REQUEST_FAILED`,
    SMS_AUTH_SUCCESS        : `SMS_AUTH_SUCCEED`,
    SMS_AUTH_FAILED         : `SMS_AUTH_FAILED`,
    INVALID_SMS_REQUEST     : `INVALID_SMS_REQUEST`,
    RESET_MY_PW_SUCCEED     : `RESET_MY_PW_SUCCEED`,
    RESET_MY_PW_FAILED      : `RESET_MY_PW_FAILED`,
    INIT_ALL_DATA_SUCCEED   : `INIT_ALL_DATA_SUCCEED`,
    INIT_USER_DATA_1_SUCCEED : `INIT_USER_DATA_1_SUCCEED`,
    INIT_USER_DATA_2_SUCCEED : `INIT_USER_DATA_2_SUCCEED`,
    TEST_SUCCEED            : `TEST_SUCCEED`,
    TEST_FAILED             : `TEST_FAILED`,
    LOGIC_EXCEPTION         : `LOGIC_EXCEPTION`
  }

  global.TXT =
    {CHANGE_TXT_HERE         : `사용할 텍스트를 입력해두기`}

  global.SEND_SMS_TYPE = {
    FIND_MY_ID : `FIND_MY_ID`,
    FIND_MY_PW : `FIND_MY_PW`
  }

  global.USTATE = {
    ATTEND_WORK       : `WORK`,              // 출근           (채용)
    ATTEND_OFF        : `OFF`,               // 휴무           (채용)
    ATTEND_EARLY_OFF  : `EARLY_OFF`,         // 조퇴           (채용)
    ATTEND_SICK_OFF   : `SICK_OFF`,          // 병가           (채용)
    ATTEND_LEAVE      : `LEAVE`,             // 퇴사           (퇴사)
    CONFIRM_REQUIRED  : `CONFIRM_REQUIRED`,  // 본인 확인 필요  (미채용)
    HIRED             : `HIRED`,             // 채용됨         (채용)
    READY             : `READY`             // 대기           (미채용)
  }

  global.USTATE_GROUP = {
    HIRED    : `HIRED`,
    NO_HIRED : `NO_HIRED`,
    LEAVE    : `LEAVE`
  }

  global.UCLASS = {
    ADMIN     : `ADMIN`,
    VIP       : `VIP`,
    MANAGER   : `MANAGER`,
    LEADER    : `LEADER`,
    MEMBER    : `MEMBER`
  }

  global.HCLASS = {
    ADMIN     : `ADMIN`,
    VIP       : `VIP`,
    MANAGER   : `MANAGER`,
    LEADER    : `LEADER`,
    MEMBER    : `MEMBER`
  }
  
  global.CCLASS = {
    POST    : `POST`,
    BOARD   : `BOARD`,
    MENU    : `MENU`
  }

  global.COMPANY = {
    DEFAULT_ID : `DEFAULT`
  }

  global.ORDER_TYPE = {
    GENERAL       : `GENERAL`,
    REWORK        : `REWORK`,
    INSPECTION    : `INSPECTION`,
    COMMISSIONING : `COMMISSIONING`
  }

  global.NOTICE_TYPE = {
    NORMAL    : `NORMAL`,
    EMERGENCY : `EMERGENCY`
  }

  global.RESIZE = {
    W         : 1920,
    H         : 1080,
    THUMB_W   : 200,
    THUMB_H   : 200,
    EXT       : `.jpg`,
    THUMB_EXT : `.thumb.jpg`
  }

  return global.log = console.log.bind(console)
}

module.exports = initGlobal()
