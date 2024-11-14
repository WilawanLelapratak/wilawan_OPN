*** Settings ***
Library                                                     RequestsLibrary
Library                                                     String

*** Variables ***
${url} =                                                    https://jsonplaceholder.typicode.com/users
${normal_status} =                                          200
${email_pattern} =                                          [!-.,@#$%^&_+\=\(\)\!\?\{\}\\\/]*[!-.,@#$%^&_+\=\(\)\!\?\{\}\\\/]@*[!0-9.,@#$%^&_+\=\(\)\!\?\{\}\\\/]*.*[!0-9.,@#$%^&_+\=\(\)\!\?\{\}\\\/]*
${website_pattern} =                                        [!.,@#$%^&_+\=\(\)\!\?\{\}\\\/]*[!.,@#$%^&_+\=\(\)\!\?\{\}\\\/]*.*[!0-9.,@#$%^&_+\=\(\)\!\?\{\}\\\/]*

*** Keywords ***
Retrieve Input
    [Arguments]    ${id}
    ${user_details_url} =                                   Set Variable                                   ${url}/${id}
    Create Session                                          TestAPI                                        ${url}
    ${res} =                                                GET On Session                                 TestAPI                                    ${user_details_url}                        expected_status=${normal_status}
    Status Should Be                                        ${normal_status}                               ${res}
    ${json_res} =                                           Set Variable                                   ${res.json()}
    ${user_name} =                                          Set Variable                                   ${json_res}[name]
    ${user_email} =                                         Set Variable                                   ${json_res}[email]
    ${user_website} =                                       Set Variable                                   ${json_res}[website]
    ${user_lat} =                                           Set Variable                                   ${json_res}[address][geo][lat]
    ${user_lng} =                                           Set Variable                                   ${json_res}[address][geo][lng]
    ${user_company_name} =                                  Set Variable                                   ${json_res}[company][name]
    ${name_result} =                                        Run Keyword And Return Status                  Should Not Be Empty                        ${user_name}
    ${email_result} =                                       Run Keyword And Return Status                  Should Match                               ${user_email}                              ${email_pattern}
    ${website_result} =                                     Run Keyword And Return Status                  Should Match                               ${user_website}                            ${website_pattern}
    ${lat_result} =                                         Run Keyword And Return Status                  Should Be True                             ${user_lat} >= -90 and ${user_lat} <= 90
    ${lng_result} =                                         Run Keyword And Return Status                  Should Be True                             ${user_lng} >= -180 and ${user_lng} <= 180
    ${company_name_result} =                                Run Keyword And Return Status                  Should Not Be Empty                        ${user_company_name}
    ${sum_result} =                                         Run Keyword And Return Status                  Should Be True                             ${name_result} and ${email_result} and ${website_result} and ${lat_result} and ${lng_result} and ${company_name_result}
    RETURN    ${user_name}    ${user_email}    ${user_website}    ${user_lat}    ${user_lng}    ${user_company_name}    ${sum_result}

*** Test Cases ***
Test_Case_001
    FOR    ${id}    IN RANGE    0    10
        ${real_id} =                                        Evaluate                                       ${id}+1
        ${user_name}    ${user_email}    ${user_website}    ${user_lat}    ${user_lng}    ${user_company_name}    ${record_valid_detail} =            Retrieve Input                             ${real_id}
        Log                                                 User Name: ${user_name}, Email: ${user_email}, Website: ${user_website}, lat: ${user_lat}, lng: ${user_lng}, Company Name: ${user_company_name}, Record Validation: ${record_valid_detail}
        IF    ${record_valid_detail} == True
            Log                                             User "${username}" get PASSED result
        ELSE
            Log                                             User "${username}" get FAILED result
        END
    END
