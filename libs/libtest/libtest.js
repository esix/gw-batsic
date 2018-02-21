

function test_case_1_res(lib_file, function_name, param, expected_result) {
    let actual_result = lib_file[function_name](param);
    
}


function test_case_1_error(lib_file, function_name, param, expected_result) {
}

module.exports = {
    test_case_1_res,
}