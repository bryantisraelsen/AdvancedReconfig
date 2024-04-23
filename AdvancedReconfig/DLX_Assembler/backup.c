#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <ctype.h>

#define MAX_LEN_DATA_NAME 64
#define MAX_LEN_INT 10   //max number of digits a number can have (10 covers over 2^32)
#define MAX_LEN_DATA_ARRAY 100
#define MAX_NUM_DATA_ENTRY 128
#define MAX_NUM_LABEL 128

struct label {   // Structure for label
  int address;           // label address it references
  char name[MAX_LEN_DATA_NAME];       // label name
};

struct data_inputted {
    char name[MAX_LEN_DATA_NAME];
    uint16_t start_address;
    uint32_t data_in[MAX_LEN_DATA_ARRAY];
    int length;
};

uint32_t reg_num(char *reg_ptr); //takes in the string and returns the number corresponding to the register
void base_add_data_name(char *arg_in, char *srch_name); //takes in the string and returns the data name (part of the string) which is used for searching the data inputted for the base_address

int main(int argc, char *argv[])  
{ 
    if (argc != 4) 
    {
        printf("Incorrect number of args given:\n\n");
        printf("Command should have the following:\n");
        printf("./dlx_asm <source_file>.dlx <data_file>.mif <code_file>.mif\n\n");
        exit(1);
    }

    size_t len = 0;
    char * line = NULL;
    FILE* src_ptr;
    FILE* data_ptr;
    FILE* code_ptr;
    FILE* debug_ptr;
    bool data = true;
    int char_cnt = 0;
    uint16_t data_instr_cnt = 0;
    uint16_t code_instr_cnt = 0;

    src_ptr = fopen(argv[1], "r"); //file ptr to source file

    // Open a file in writing mode for data file
    data_ptr = fopen(argv[2], "w");

    //open a file in writing mode for a code file
    code_ptr = fopen(argv[3], "w");

    //open a file in writing mode for a debug file
    debug_ptr = fopen("debug.txt", "w");

    if (NULL == src_ptr)
    {
        printf("Error, source file can't be opened \n");
        exit(1);
    }
    uint32_t cnt = 0;
    char* token;
    bool data_name_read = false;
    bool data_name_middle = false;
    char data_name[MAX_LEN_DATA_NAME];
    char data_len_ptr[MAX_LEN_INT];
    char data_in_ptr[MAX_LEN_INT];
    char label_name[MAX_LEN_DATA_NAME];
    int data_in_start, data_in_end;
    bool data_in_read = false;
    bool data_in_middle = false;
    int data_len, data_in_individual; 
    int* data_in;
    int data_name_start, data_name_end;
    int data_len_start, data_len_end;
    bool data_len_read = false;
    bool data_len_middle = false;
    int data_in_cnt = 0;
    int data_entry_cnt = 0;
    uint16_t instruct_cnt = 0;
    uint32_t machine_code = 0;
    uint32_t opcode = 0; //is 6 bits in length
    uint16_t immediate = 0; //immediate value has 16 bits
    uint32_t register0 = 0; //register address is 5 bits
    uint32_t register1 = 0;
    bool label_name_read = false;
    bool label_name_mid = false;
    int label_name_end = 0;
    uint16_t code_inst_cnt = 0;
    struct data_inputted data_recorded[MAX_NUM_DATA_ENTRY];
    struct label labels_recorded[MAX_NUM_LABEL];
    int label_cnt = 0;
    bool starting_code = false;
    bool comment_line = false;
    bool some_text = false;
    

    //write the header portion
    fprintf(data_ptr, "DEPTH = 1024;\nWIDTH = 32;\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\nCONTENT\nBEGIN\n\n");  //write header part
    fprintf(code_ptr, "DEPTH = 1024;\nWIDTH = 32;\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\nCONTENT\nBEGIN\n\n");  //write header part

    while ((getline(&line, &len, src_ptr)) != -1)
    {
        fprintf(debug_ptr, line);
        data_name_middle = false;
        data_name_read = false;
        data_len_read = false;
        data_len_middle = false;
        data_in_read = false;
        data_in_middle = false;
        data_in_cnt = 0;
        cnt += 1;
        if (line[0] == ';') //line is a comment
        {
            continue;
        }
        if (data == true)  //write to data file
        {
            if (strstr(line, ".text"))  //moving to text portion of file
            {
                data = false;
            }
            else if (strstr(line, ".data"))
            {
                continue;
            }
            else
            {
                for(int i = 0; i < strlen(line); i++)
                {
                    if (data_name_middle == false)
                    {
                        if (!isspace(line[i]))
                        {
                            data_name_start = i;
                            data_name_middle = true;
                        }
                    }
                    else if (data_name_read == false)
                    {
                        if (isspace(line[i]))
                        {
                            data_name_end = i-1;
                            data_name_read = true;
                            strncpy(data_name, line+data_name_start, data_name_end-data_name_start+1);
                            data_name[data_name_end-data_name_start+1] = '\0';
                        }
                    }
                    else if (data_len_middle == false)
                    {
                        if (!isspace(line[i]))
                        {
                            data_len_start = i;
                            data_len_middle = true;
                        }
                    }
                    else if (data_len_read == false)
                    {
                        if (isspace(line[i]))
                        {
                            data_len_end = i-1;
                            data_len_read = true;
                            strncpy(data_len_ptr, line+data_len_start, data_len_end-data_len_start+1);
                            data_len_ptr[data_len_end-data_len_start+1] = '\0';
                            data_len = atoi(data_len_ptr);
                        }
                    }
                    else if (data_in_middle == false)
                    {
                        if (!isspace(line[i]))
                        {
                            data_in_start = i;
                            data_in_middle = true;
                        }
                    }
                    else if (data_in_read == false)
                    {
                        if (isspace(line[i]))
                        {
                            data_in_end = i-1;
                            strncpy(data_in_ptr, line+data_in_start, data_in_end-data_in_start+1);
                            data_in_ptr[data_in_end-data_in_start+1] = '\0';
                            data_in_individual = atoi(data_in_ptr);
                            fprintf(data_ptr, "%.3X : %.8X; --%s[%d]\n", instruct_cnt, (uint32_t)data_in_individual, data_name, data_in_cnt);
                            if (data_in_cnt == 0)
                            {
                                strncpy(data_recorded[data_entry_cnt].name, data_name, data_name_end-data_name_start+2);
                                data_recorded[data_entry_cnt].start_address = instruct_cnt;
                                data_recorded[data_entry_cnt].length = data_len;
                            }
                            data_recorded[data_entry_cnt].data_in[data_in_cnt] = (uint32_t)data_in_individual;
                            data_in_cnt++;
                            instruct_cnt++;
                            if (data_in_cnt >= data_len)
                            {
                                data_in_read = true;
                                data_entry_cnt++;
                                //make a struct for storing data
                            }
                            else
                            {
                                data_in_middle = false;
                            }
                        }
                    }
                }
            }
        }
        else
        {
            // printf("out of data portion, now on line %d\n", cnt);
            if (!isspace(line[0]))
            {
                for(int i = 0; i < strlen(line); i++)
                {
                    if (label_name_mid == false)
                    {
                        label_name_mid = true;
                    }
                    else if (label_name_read == false)
                    {
                        if (isspace(line[i]))
                        {
                            label_name_end = i-1;
                            label_name_read = true;
                            strncpy(label_name, line, label_name_end+1);
                            label_name[label_name_end+1] = '\0';
                            strncpy(labels_recorded[label_cnt].name, label_name, label_name_end+2);
                            labels_recorded[label_cnt].address = code_inst_cnt;
                            label_cnt++;
                            // printf("label_name is %s\n", label_name);
                            // printf("label number %d made for label %s, it has the address of %x\n", label_cnt, labels_recorded[label_cnt-1].name, labels_recorded[label_cnt-1].address);
                            //add struct for a label (what it's address is going to)
                        }
                    }
                }
            }
            else  //not a label
            {
                for (int j = 0; j < strlen(line); j++)
                {
                    if (!isspace(line[j]))
                    {
                        if (line[j] == ';')
                        {
                            comment_line = true;
                            break;
                        }
                        else
                        {
                            some_text = true;
                        }
                    }
                }
                if (comment_line == false && some_text == true)
                {
                    // printf("got code line for line %d which has the string: %s\n", code_inst_cnt, line);
                    code_inst_cnt++;
                }
            }
        }
        label_name_read = false;
        label_name_mid = false;
        comment_line = false;
        some_text = false;
    }
    // printf("out of first loop of reading from the fil, has %d labels recorded\n", label_cnt);

    int op_code_start = 0;
    int op_code_end = 0;
    bool op_code_mid = false;
    bool op_code_read = false;
    char op_code_str[6];  //max len of 6 (so we can add '\0' character)
    char arg0_str[MAX_LEN_DATA_NAME]; 
    char arg1_str[MAX_LEN_DATA_NAME];
    char arg2_str[MAX_LEN_DATA_NAME];
    bool arg0_read = false;
    bool arg0_mid = false;
    bool arg1_read = false;
    bool arg1_mid = false;
    bool arg2_read = false;
    bool arg2_mid = false;
    bool mem_instruct = false;
    bool jump_inst = false;
    bool jump_w_label = false;
    bool L_inst = false;
    int arg0_start;
    int arg0_end;
    int arg1_start;
    int arg1_end;
    int arg2_start;
    int arg2_end;
    uint32_t reg_dest, reg_0, reg_1, base_add_imme;
    char srch_name[MAX_LEN_DATA_NAME];
    bool commented_line = false;
    bool branch_inst = false;
    char comment_for_file[MAX_LEN_DATA_ARRAY];

    //bool ST_inst = false;

    src_ptr = fopen(argv[1], "r"); //file ptr to source file
    code_inst_cnt = 0;
    while ((getline(&line, &len, src_ptr)) != -1)  //going through the file for the second time (after labels were all recorded)
    {
        mem_instruct = false;
        L_inst = false;
        jump_inst = false;
        jump_w_label = false;
        commented_line = false;
        branch_inst = false;
        // ST_inst = false;
        // printf("reading for second time\n");
        if (strstr(line, ".text"))
        {
            printf("Reading data now\n");
            starting_code = true;
        }
        else if (starting_code)
        {
            if (!isspace(line[0])) //label so don't worry about it
            {
                // printf("Label on this line so don't worry about it\n");
                continue;
            }
            else if (commented_line == false)
            {
                // printf("instruction now\n\n");
                for(int i = 0; i < strlen(line); i++)
                {
                    if (op_code_mid == false)
                    {
                        if (!isspace(line[i]))
                        {
                            // printf("Frist character of this opcode is %c\n", line[i]);
                            op_code_start = i;
                            op_code_mid = true;
                            if (line[i] == ';')
                            {
                                commented_line = true;
                                continue;
                            }
                        }
                    }
                    else if (op_code_read == false)
                    {
                        if (isspace(line[i]))
                        {
                            op_code_end = i-1;
                            op_code_read = true;
                            // printf("Last character of this opcode is %c\n", line[i-1]);
                            // op_code_str[op_code_end] = '\0';
                            strncpy(op_code_str, line+op_code_start, op_code_end-op_code_start+1);
                            op_code_str[op_code_end-op_code_start+1] = '\0';
                            // printf("Opcode is %s\n", op_code_str);
                            //make opcode depending on the op_code_str
                            if (strcmp("NOP",op_code_str) == 0)
                            {
                                opcode = 0;
                                arg0_mid = true;
                                arg0_read = true;
                                arg1_mid = true;
                                arg1_read = true;
                                arg2_mid = true;
                                arg2_read = true;
                            }
                            else if (strcmp("LW",op_code_str) == 0)
                            {
                                opcode = 1 << 26;
                                mem_instruct = true;
                                L_inst = true;
                            }
                            else if (strcmp("SW",op_code_str) == 0)
                            {
                                opcode = 2 << 26;
                                mem_instruct = true;
                                // ST_inst = true;
                            }
                            else if (strcmp("ADD",op_code_str) == 0)
                            {
                                opcode = 3 << 26;
                            }
                            else if (strcmp("ADDI",op_code_str) == 0)
                            {
                                // printf("This opcode was ADDI\n");
                                opcode = 4 << 26;
                            }
                            else if (strcmp("ADDU",op_code_str) == 0)
                            {
                                opcode = 5 << 26;
                            }
                            else if (strcmp("ADDUI",op_code_str) == 0)
                            {
                                opcode = 6 << 26;
                            }
                            else if (strcmp("SUB",op_code_str) == 0)
                            {
                                opcode = 7 << 26;
                            }
                            else if (strcmp("SUBI",op_code_str) == 0)
                            {
                                opcode = 8 << 26;
                            }
                            else if (strcmp("SUBU",op_code_str) == 0)
                            {
                                opcode = 9 << 26;
                            }
                            else if (strcmp("SUBUI",op_code_str) == 0)
                            {
                                opcode = 10 << 26;
                            }
                            else if (strcmp("AND",op_code_str) == 0)
                            {
                                opcode = 11 << 26;
                            }
                            else if (strcmp("ANDI",op_code_str) == 0)
                            {
                                opcode = 12 << 26;
                            }
                            else if (strcmp("OR",op_code_str) == 0)
                            {
                                opcode = 13 << 26;
                            }
                            else if (strcmp("ORI",op_code_str) == 0)
                            {
                                opcode = 14 << 26;
                            }
                            else if (strcmp("XOR",op_code_str) == 0)
                            {
                                opcode = 15 << 26;
                            }
                            else if (strcmp("XORI",op_code_str) == 0)
                            {
                                opcode = 16 << 26;
                            }
                            else if (strcmp("SLL",op_code_str) == 0)
                            {
                                opcode = 17 << 26;
                            }
                            else if (strcmp("SLLI",op_code_str) == 0)
                            {
                                opcode = 18 << 26;
                            }
                            else if (strcmp("SRL",op_code_str) == 0)
                            {
                                opcode = 19 << 26;
                            }
                            else if (strcmp("SRLI",op_code_str) == 0)
                            {
                                opcode = 20 << 26;
                            }
                            else if (strcmp("SRA",op_code_str) == 0)
                            {
                                opcode = 21 << 26;
                            }
                            else if (strcmp("SRAI",op_code_str) == 0)
                            {
                                opcode = 22 << 26;
                            }
                            else if (strcmp("SLT",op_code_str) == 0)
                            {
                                opcode = 23 << 26;
                            }
                            else if (strcmp("SLTI",op_code_str) == 0)
                            {
                                opcode = 24 << 26;
                            }
                            else if (strcmp("SLTU",op_code_str) == 0)
                            {
                                opcode = 25 << 26;
                            }
                            else if (strcmp("SLTUI",op_code_str) == 0)
                            {
                                opcode = 26 << 26;
                            }
                            else if (strcmp("SGT",op_code_str) == 0)
                            {
                                opcode = 27 << 26;
                            }
                            else if (strcmp("SGTI",op_code_str) == 0)
                            {
                                opcode = 28 << 26;
                            }
                            else if (strcmp("SGTU",op_code_str) == 0)
                            {
                                opcode = 29 << 26;
                            }
                            else if (strcmp("SGTUI",op_code_str) == 0)
                            {
                                opcode = 30 << 26;
                            }
                            else if (strcmp("SLE",op_code_str) == 0)
                            {
                                opcode = 31 << 26;
                            }
                            else if (strcmp("SLEI",op_code_str) == 0)
                            {
                                opcode = 32 << 26;
                            }
                            else if (strcmp("SLEU",op_code_str) == 0)
                            {
                                opcode = 33 << 26;
                            }
                            else if (strcmp("SLEUI",op_code_str) == 0)
                            {
                                opcode = 34 << 26;
                            }
                            else if (strcmp("SGE",op_code_str) == 0)
                            {
                                opcode = 35 << 26;
                            }
                            else if (strcmp("SGEI",op_code_str) == 0)
                            {
                                opcode = 36 << 26;
                            }
                            else if (strcmp("SGEU",op_code_str) == 0)
                            {
                                opcode = 37 << 26;
                            }
                            else if (strcmp("SGEUI",op_code_str) == 0)
                            {
                                opcode = 38 << 26;
                            }
                            else if (strcmp("SEQ",op_code_str) == 0)
                            {
                                opcode = 39 << 26;
                            }
                            else if (strcmp("SEQI",op_code_str) == 0)
                            {
                                opcode = 40 << 26;
                            }
                            else if (strcmp("SNE",op_code_str) == 0)
                            {
                                opcode = 41 << 26;
                            }
                            else if (strcmp("SNEI",op_code_str) == 0)
                            {
                                opcode = 42 << 26;
                            }
                            else if (strcmp("BEQZ",op_code_str) == 0)
                            {
                                opcode = 43 << 26;
                                branch_inst = true;
                            }
                            else if (strcmp("BNEZ",op_code_str) == 0)
                            {
                                opcode = 44 << 26;
                                branch_inst = true;
                            }
                            else if (strcmp("J",op_code_str) == 0)
                            {
                                jump_inst = true;
                                jump_w_label = true;
                                opcode = 45 << 26;
                            }
                            else if (strcmp("JR",op_code_str) == 0)
                            {
                                jump_inst = true;
                                opcode = 46 << 26;
                            }
                            else if (strcmp("JAL",op_code_str) == 0)
                            {
                                jump_inst = true;
                                jump_w_label = true;
                                opcode = 47 << 26;
                            }
                            else if (strcmp("JALR",op_code_str) == 0)
                            {
                                jump_inst = true;
                                opcode = 48 << 26;
                            }
                            else if (op_code_str[0] == ';')
                            {
                                continue;
                            }
                            strncpy(comment_for_file, line, strlen(line)-1);
                            comment_for_file[strlen(line)-1] = '\0';
                            // printf("cmd was %s for instruction #%d\n", op_code_str, code_inst_cnt);
                            // fprintf(code_ptr, "%.3X : %.8X\n", code_inst_cnt, opcode); //for debugging
                            code_inst_cnt++;
                        }
                    }
                    else if (mem_instruct)
                    {
                        if (L_inst)  //if Load mem then we have offset with base address on second arg (adjust accordingly for the second arg)
                        {
                            if (arg0_mid == false)
                            {
                                if (!isspace(line[i]))
                                {
                                    // printf("Frist character of arg0 is %c\n", line[i]);
                                    arg0_start = i;
                                    arg0_mid = true;
                                }
                            }
                            else if (arg0_read == false)
                            {
                                if (line[i] == ',')
                                {
                                    // printf("Last character of arg0 is %c\n", line[i-1]);
                                    arg0_end = i-1;
                                    arg0_str[arg0_end-arg0_start+1] = '\0';
                                    strncpy(arg0_str, line+arg0_start, arg0_end-arg0_start+1);
                                    // printf("arg0 is %s\n", arg0_str);
                                    // printf("reg_dest = %x\n", reg_dest);
                                    reg_dest = reg_num(arg0_str);
                                    // printf("reg_dest = %x\n", reg_dest);
                                    reg_dest = reg_dest << 21;
                                    // printf("reg_dest = %x\n", reg_dest);
                                    arg0_read = true;
                                }
                            }
                            else if (arg1_mid == false)
                            {
                                if (!isspace(line[i]))
                                {
                                    // printf("Frist character of arg1 is %c\n", line[i]);
                                    arg1_start = i;
                                    arg1_mid = true;
                                }
                            }
                            else if (arg1_read == false)
                            {
                                if (isspace(line[i]))
                                {
                                    // printf("Last character of arg1 is %c\n", line[i-1]);
                                    arg1_end = i-1;
                                    arg1_str[arg1_end-arg1_start+1] = '\0';
                                    strncpy(arg1_str, line+arg1_start, arg1_end-arg1_start+1);
                                    // printf("arg1 is %s\n", arg1_str);
                                    reg_0 = reg_num(arg1_str) << 16;
                                    // printf("reg_0 = %x\n", reg_0);
                                    base_add_data_name(arg1_str, srch_name);
                                    for (int j = 0; j < data_entry_cnt; j++)
                                    {
                                        if (strcmp(data_recorded[j].name, srch_name) == 0)
                                        {
                                            base_add_imme = (uint32_t)data_recorded[j].start_address;
                                        }
                                    }
                                    arg1_read = true;
                                    // printf("base address is %x\n", base_add_imme);
                                    // printf("opcode = %x, reg_dest = %x, reg_0 = %x\n", opcode, reg_dest, reg_0);
                                    machine_code = opcode + reg_dest + reg_0 + base_add_imme;
                                    fprintf(code_ptr, "%.3X : %.8X\t--%s\n", code_inst_cnt - 1, machine_code, comment_for_file);
                                }
                            }
                        }
                        else //if Store mem then we have offset with base address on first arg (adjust accordingly for the frist arg)
                        {
                            if (arg0_mid == false)
                            {
                                if (!isspace(line[i]))
                                {
                                    // printf("Frist character of arg0 is %c\n", line[i]);
                                    arg0_start = i;
                                    arg0_mid = true;
                                }
                            }
                            else if (arg0_read == false)
                            {
                                if (line[i] == ',')
                                {
                                    // printf("Last character of arg0 is %c\n", line[i-1]);
                                    arg0_end = i-1;
                                    arg0_str[arg0_end-arg0_start+1] = '\0';
                                    strncpy(arg0_str, line+arg0_start, arg0_end-arg0_start+1);
                                    base_add_data_name(arg0_str, srch_name);
                                    for (int j = 0; j < data_entry_cnt; j++)
                                    {
                                        if (strcmp(data_recorded[j].name, srch_name) == 0)
                                        {
                                            base_add_imme = (uint32_t)data_recorded[j].start_address;
                                        }
                                    }
                                    reg_0 = reg_num(arg0_str) << 16;
                                    // printf("arg0 is %s\n", arg0_str);
                                    arg0_read = true;
                                }
                            }
                            else if (arg1_mid == false)
                            {
                                if (!isspace(line[i]))
                                {
                                    // printf("Frist character of arg1 is %c\n", line[i]);
                                    arg1_start = i;
                                    arg1_mid = true;
                                }
                            }
                            else if (arg1_read == false)
                            {
                                if (isspace(line[i]))
                                {
                                    // printf("Last character of arg1 is %c\n", line[i-1]);
                                    arg1_end = i-1;
                                    arg1_str[arg1_end-arg1_start+1] = '\0';
                                    strncpy(arg1_str, line+arg1_start, arg1_end-arg1_start+1);
                                    reg_dest = reg_num(arg1_str);
                                    // printf("reg_dest = %x\n", reg_dest);
                                    reg_dest = reg_dest << 21;
                                    // printf("arg1 is %s\n", arg1_str);
                                    arg1_read = true;
                                    machine_code = opcode + reg_dest + reg_0 + base_add_imme;
                                    fprintf(code_ptr, "%.3X : %.8X\t--%s\n", code_inst_cnt - 1, machine_code, comment_for_file);
                                }
                            }
                        }
                    }
                    else if (jump_inst)
                    {
                        if (jump_w_label)  //when creating the commands, do it differently with a label vs without a label
                        {
                            if (arg0_mid == false)
                            {
                                if (!isspace(line[i]))
                                {
                                    // printf("Frist character of arg0 is %c\n", line[i]);
                                    arg0_start = i;
                                    arg0_mid = true;
                                }
                            }
                            else if (arg0_read == false)
                            {
                                if (isspace(line[i]))
                                {
                                    // printf("Last character of arg0 is %c\n", line[i-1]);
                                    arg0_end = i-1;
                                    arg0_str[arg0_end-arg0_start+1] = '\0';
                                    strncpy(arg0_str, line+arg0_start, arg0_end-arg0_start+1);
                                    // printf("arg0 is %s\n", arg0_str);
                                    // printf("label cnt is %d\n", label_cnt);
                                    for (int j = 0; j < label_cnt; j++)
                                    {
                                        // printf("comparing %s with %s\n", arg0_str, labels_recorded[j].name);
                                        if (strcmp(labels_recorded[j].name, arg0_str) == 0)
                                        {
                                            // printf("match for label %s\n", arg0_str);
                                            base_add_imme = (uint32_t)labels_recorded[j].address;
                                        }
                                    }
                                    arg0_read = true;
                                    machine_code = opcode + base_add_imme;
                                    // printf("base address is %x\n", base_add_imme);
                                    fprintf(code_ptr, "%.3X : %.8X\t--%s\n", code_inst_cnt - 1, machine_code, comment_for_file);
                                }
                            }
                        }
                        else
                        {
                            if (arg0_mid == false)
                            {
                                if (!isspace(line[i]))
                                {
                                    // printf("Frist character of arg0 is %c\n", line[i]);
                                    arg0_start = i;
                                    arg0_mid = true;
                                }
                            }
                            else if (arg0_read == false)
                            {
                                if (isspace(line[i]))
                                {
                                    // printf("Last character of arg0 is %c\n", line[i-1]);
                                    arg0_end = i-1;
                                    arg0_str[arg0_end-arg0_start+1] = '\0';
                                    strncpy(arg0_str, line+arg0_start, arg0_end-arg0_start+1);
                                    // printf("arg0 is %s\n", arg0_str);
                                    base_add_imme = reg_num(arg0_str);
                                    // printf("reg # found is %d\n", base_add_imme);
                                    machine_code = opcode + base_add_imme;
                                    fprintf(code_ptr, "%.3X : %.8X\t--%s\n", code_inst_cnt - 1, machine_code, comment_for_file);
                                    arg0_read = true;
                                }
                            }
                        }
                    }
                    else if (branch_inst)
                    {
                        if (arg0_mid == false)
                        {
                            if (!isspace(line[i]))
                            {
                                // printf("Frist character of arg0 is %c\n", line[i]);
                                arg0_start = i;
                                arg0_mid = true;
                            }
                        }
                        else if (arg0_read == false)
                        {
                            if (line[i] == ',')
                            {
                                // printf("Last character of arg0 is %c\n", line[i-1]);
                                arg0_end = i-1;
                                arg0_str[arg0_end-arg0_start+1] = '\0';
                                strncpy(arg0_str, line+arg0_start, arg0_end-arg0_start+1);
                                reg_dest = reg_num(arg0_str);
                                reg_dest = reg_dest << 21;
                                // printf("arg0 is %s\n", arg0_str);
                                arg0_read = true;
                            }
                        }
                        else if (arg1_mid == false)
                        {
                            if (!isspace(line[i]))
                            {
                                // printf("Frist character of arg1 is %c\n", line[i]);
                                arg1_start = i;
                                arg1_mid = true;
                            }
                        }
                        else if (arg1_read == false)
                        {
                            if (isspace(line[i]))
                            {
                                // printf("Last character of arg1 is %c\n", line[i-1]);
                                arg1_end = i-1;
                                arg1_str[arg1_end-arg1_start+1] = '\0';
                                strncpy(arg1_str, line+arg1_start, arg1_end-arg1_start+1);
                                for (int j = 0; j < label_cnt; j++)
                                {
                                    // printf("comparing %s with %s\n", arg0_str, labels_recorded[j].name);
                                    if (strcmp(labels_recorded[j].name, arg1_str) == 0)
                                    {
                                        // printf("match for label %s\n", arg0_str);
                                        base_add_imme = (uint32_t)labels_recorded[j].address;
                                    }
                                }
                                machine_code = opcode + reg_dest+ base_add_imme;
                                // printf("base address is %x\n", base_add_imme);
                                arg1_read = true;
                                // machine_code = opcode + reg_dest + reg_0 + base_add_imme;
                                fprintf(code_ptr, "%.3X : %.8X\t--%s\n", code_inst_cnt - 1, machine_code, comment_for_file);
                            }
                        }

                    }
                    else if (op_code_str[op_code_end-op_code_start] == 'I')  //has immediate value for last arg
                    {
                        //added from here down
                        if (arg0_mid == false)
                        {
                            if (!isspace(line[i]))
                            {
                                // printf("Frist character of arg0 is %c\n", line[i]);
                                arg0_start = i;
                                arg0_mid = true;
                            }
                        }
                        else if (arg0_read == false)
                        {
                            if (line[i] == ',')
                            {
                                // printf("Last character of arg0 is %c\n", line[i-1]);
                                arg0_end = i-1;
                                arg0_str[arg0_end-arg0_start+1] = '\0';
                                strncpy(arg0_str, line+arg0_start, arg0_end-arg0_start+1);
                                // printf("arg0 is %s\n", arg0_str);
                                // printf("reg_dest = %x\n", reg_dest);
                                reg_dest = reg_num(arg0_str);
                                // printf("reg_dest = %x\n", reg_dest);
                                reg_dest = reg_dest << 21;
                                // printf("reg_dest = %x\n", reg_dest);
                                arg0_read = true;
                            }
                        }
                        else if (arg1_mid == false)
                        {
                            if (!isspace(line[i]))
                            {
                                // printf("Frist character of arg1 is %c\n", line[i]);
                                arg1_start = i;
                                arg1_mid = true;
                            }
                        }
                        else if (arg1_read == false)
                        {
                            if (isspace(line[i]))
                            {
                                // printf("Last character of arg1 is %c\n", line[i-1]);
                                arg1_end = i-1;
                                arg1_str[arg1_end-arg1_start+1] = '\0';
                                strncpy(arg1_str, line+arg1_start, arg1_end-arg1_start+1);
                                // printf("arg1 is %s\n", arg1_str);
                                reg_0 = reg_num(arg1_str) << 16;
                                arg1_read = true;
                                // printf("base address is %x\n", base_add_imme);
                                // printf("opcode = %x, reg_dest = %x, reg_0 = %x\n", opcode, reg_dest, reg_0);
                                // machine_code = opcode + reg_dest + reg_0 + base_add_imme;
                                // fprintf(code_ptr, "%.3X : %.8X\n", code_inst_cnt - 1, machine_code);
                            }
                        }
                        else if (arg2_mid == false)
                        {
                            if (!isspace(line[i]))
                            {
                                // printf("Frist character of arg1 is %c\n", line[i]);
                                arg2_start = i;
                                arg2_mid = true;
                            }
                        }
                        else if (arg2_read == false)
                        {
                            if (isspace(line[i]))
                            {
                                // printf("Last character of arg1 is %c\n", line[i-1]);
                                arg2_end = i-1;
                                arg2_str[arg2_end-arg2_start+1] = '\0';
                                strncpy(arg2_str, line+arg2_start, arg2_end-arg2_start+1);
                                // printf("arg1 is %s\n", arg1_str);
                                base_add_imme = (uint32_t)atoi(arg2_str);
                                arg2_read = true;
                                // printf("base address is %x\n", base_add_imme);
                                // printf("opcode = %x, reg_dest = %x, reg_0 = %x\n", opcode, reg_dest, reg_0);
                                machine_code = opcode + reg_dest + reg_0 + base_add_imme;
                                fprintf(code_ptr, "%.3X : %.8X\t--%s\n", code_inst_cnt - 1, machine_code, comment_for_file);
                            }
                        }

                    }
                    else  //no immediate value (3 reg args)
                    {
                        if (arg0_mid == false)
                        {
                            if (!isspace(line[i]))
                            {
                                // printf("Frist character of arg0 is %c\n", line[i]);
                                arg0_start = i;
                                arg0_mid = true;
                            }
                        }
                        else if (arg0_read == false)
                        {
                            if (line[i] == ',')
                            {
                                // printf("Last character of arg0 is %c\n", line[i-1]);
                                arg0_end = i-1;
                                arg0_str[arg0_end-arg0_start+1] = '\0';
                                strncpy(arg0_str, line+arg0_start, arg0_end-arg0_start+1);
                                // printf("arg0 is %s\n", arg0_str);
                                // printf("reg_dest = %x\n", reg_dest);
                                reg_dest = reg_num(arg0_str);
                                // printf("reg_dest = %x\n", reg_dest);
                                reg_dest = reg_dest << 21;
                                // printf("reg_dest = %x\n", reg_dest);
                                arg0_read = true;
                            }
                        }
                        else if (arg1_mid == false)
                        {
                            if (!isspace(line[i]))
                            {
                                // printf("Frist character of arg1 is %c\n", line[i]);
                                arg1_start = i;
                                arg1_mid = true;
                            }
                        }
                        else if (arg1_read == false)
                        {
                            if (isspace(line[i]))
                            {
                                // printf("Last character of arg1 is %c\n", line[i-1]);
                                arg1_end = i-1;
                                arg1_str[arg1_end-arg1_start+1] = '\0';
                                strncpy(arg1_str, line+arg1_start, arg1_end-arg1_start+1);
                                // printf("arg1 is %s\n", arg1_str);
                                reg_0 = reg_num(arg1_str) << 16;
                                arg1_read = true;
                                // printf("base address is %x\n", base_add_imme);
                                // printf("opcode = %x, reg_dest = %x, reg_0 = %x\n", opcode, reg_dest, reg_0);
                                // machine_code = opcode + reg_dest + reg_0 + base_add_imme;
                                // fprintf(code_ptr, "%.3X : %.8X\n", code_inst_cnt - 1, machine_code);
                            }
                        }
                        else if (arg2_mid == false)
                        {
                            if (!isspace(line[i]))
                            {
                                // printf("Frist character of arg1 is %c\n", line[i]);
                                arg2_start = i;
                                arg2_mid = true;
                            }
                        }
                        else if (arg2_read == false)
                        {
                            if (isspace(line[i]))
                            {
                                // printf("Last character of arg1 is %c\n", line[i-1]);
                                arg2_end = i-1;
                                arg2_str[arg2_end-arg2_start+1] = '\0';
                                strncpy(arg2_str, line+arg2_start, arg2_end-arg2_start+1);
                                // printf("arg2 is %s\n", arg2_str);
                                reg_1 = reg_num(arg2_str) << 11;
                                arg2_read = true;
                                // printf("base address is %x\n", base_add_imme);
                                // printf("opcode = %x, reg_dest = %x, reg_0 = %x\n", opcode, reg_dest, reg_0);
                                machine_code = opcode + reg_dest + reg_0 + reg_1;
                                fprintf(code_ptr, "%.3X : %.8X\t--%s\n", code_inst_cnt - 1, machine_code, comment_for_file);
                            }
                        }
                    }
                }
            }
        }
        op_code_mid = false;
        op_code_read = false;
        arg0_mid = false;
        arg0_read = false;
        arg1_mid = false;
        arg1_read = false;
        arg2_mid = false;
        arg2_read = false;
    }


    // for (int i = 0; i  < label_cnt; i++)
    // {
    //     printf("labels_recorded[%d].name = %s, labels_recorded[%d].address = %x\n", i, labels_recorded[i].name, i, labels_recorded[i].address);
    // }
    fprintf(data_ptr, "\nEND;");  //write END and close file
    fprintf(code_ptr, "\nEND;");  //write END and close file

    // Close the files
    fclose(debug_ptr);
    fclose(data_ptr);
    fclose(code_ptr);
      
    return 0; 
} 

uint32_t reg_num(char *reg_ptr)
{
    uint32_t reg_num_found;
    int i, reg_num_start, reg_num_end;
    char num_ptr[MAX_LEN_INT];
    // printf("entered the reg function that returns the number\n");
    for(i = 0; i <= strlen(reg_ptr); i++)
    {
        if (reg_ptr[i] == 'R')
        {
            reg_num_start = i + 1;
            // printf("First if statment and have %s as input with a string len of %d\n", reg_ptr, strlen(reg_ptr));
        }
        else if (i == strlen(reg_ptr) || reg_ptr[i] == ',' || isspace(reg_ptr[i]) || reg_ptr[i] == ')')
        {
            // printf("Enterd second if statement and have %s as the input", reg_ptr);
            reg_num_end = i - 1;
            num_ptr[reg_num_end-reg_num_start+1] = '\0';
            strncpy(num_ptr, reg_ptr+reg_num_start, reg_num_end-reg_num_start+1);
            // printf("num is %s\n", num_ptr);
        }
    }
    reg_num_found = (uint32_t)atoi(num_ptr);
    return reg_num_found;
}

void base_add_data_name(char *arg_in, char *srch_name)
{
    char data_name[MAX_LEN_DATA_NAME];
    int i, data_name_end;
    for(i = 0; i < strlen(arg_in); i++)
    {
        if(arg_in[i] == '(')
        {
            data_name_end = i - 1;
            srch_name[data_name_end+1] = '\0';
            strncpy(srch_name, arg_in, data_name_end+1);
            // printf("arg_in is %s, data name is %s\n", arg_in, srch_name);
            break;
        }
    }
    return;
}