module question1;
int arr[] = '{9,7,4,6,2,8,6,5};
int arr_odd[$];
int arr_even[$];
initial begin
    arr=arr.unique();
    $display(arr);
    foreach(arr[i]) begin
        if(arr[i]%2==0) arr_even.push_back(arr[i]);
        else            arr_odd.push_back(arr[i]);
    end
    $display("Even :%p",arr_even);
    $display("Odd :%p",arr_odd);
end
endmodule