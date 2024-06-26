import tkinter as tk
from tkinter import simpledialog, messagebox, Text
import subprocess
import threading

app_config = {
    "GIMP": {
        "script": "./script.sh",
        "functionalitati": {
            "Aplicare filtru alb-negru": "1",
            "Redimensionarea imaginii": "2",
            "Rotirea imaginii": "3",
            "Adaugarea unui text": "4"
        }
    }
}

def load_safe_syscalls(file_path):
    with open(file_path, 'r') as file:
        safe_syscalls = set(line.strip() for line in file)
    return safe_syscalls

def run_bash_script(script_path, func_code, extra_args=[], output_widget=None):
    safe_syscalls = load_safe_syscalls("safe_syscalls.txt")
    
    try:
        command = [script_path, func_code] + extra_args
        print(f"Rulam comanda: {command}")
        
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        
        def read_output():
            for line in iter(process.stdout.readline, ''):
                print(line.strip())
                output_widget.insert(tk.END, line)
                output_widget.see(tk.END)
            process.stdout.close()
            process.wait()
            output_widget.config(state=tk.DISABLED)
            check_unsafe_syscalls(func_code)
        
        def check_unsafe_syscalls(func_code):
            if func_code == '1':
                log_file = 'stracebw.log'
            elif func_code == '2':
                log_file = 'stracers.log'
            elif func_code == '3':
                log_file = 'stracerot.log'
            else:
                log_file = 'stracetxt.log'
            with open(log_file, 'r') as f:
                log = f.read()

            log_syscalls = set(line.split('(')[0].strip() for line in log.splitlines())
            unsafe_syscalls = log_syscalls - safe_syscalls

            unsafe_output_window = tk.Toplevel(output_widget.master)
            unsafe_output_window.title("Apeluri de sistem nesigure")
            unsafe_output_text = Text(unsafe_output_window, wrap=tk.WORD, height=20, width=50)
            unsafe_output_text.pack(padx=10, pady=10, fill=tk.BOTH, expand=True)

            unsafe_output_text.insert(tk.END, "Apeluri de sistem nesigure:\n")
            syscall_frames = {}

            for syscall in unsafe_syscalls:
                syscall_frame = tk.Frame(unsafe_output_text)
                syscall_frame.pack(fill=tk.X)
    
                syscall_label = tk.Label(syscall_frame, text=f"{syscall}")
                syscall_label.pack(side=tk.LEFT, padx=5)
    
                def mark_as_safe(syscall=syscall, frame=syscall_frame):
                    with open("safe_syscalls.txt", "a") as f:
                        f.write("\n" + syscall)
                    messagebox.showinfo("Succes", f"Apelul de sistem '{syscall}' a fost marcat ca safe!")
                    frame.destroy()
                    unsafe_syscalls.discard(syscall)  

                mark_safe_button = tk.Button(syscall_frame, text="Marcati ca safe", command=lambda syscall=syscall, frame=syscall_frame: mark_as_safe(syscall, frame))
                mark_safe_button.pack(side=tk.RIGHT, padx=5)

                syscall_frames[syscall] = syscall_frame

            unsafe_output_text.config(state=tk.NORMAL)

        threading.Thread(target=read_output).start()
        output_widget.config(state=tk.NORMAL)
    except Exception as e:
        output_widget.insert(tk.END, str(e) + '\n')

def start_page(root, config):
    root.geometry('300x150')
    app_name_label = tk.Label(root, text="Selectati aplicatia:")
    app_name_label.pack(pady=10)
    
    app_var = tk.StringVar(root)
    app_var.set(list(config.keys())[0])
    app_menu = tk.OptionMenu(root, app_var, *config.keys())
    app_menu.pack(pady=10)
    
    def go_to_functionalities():
        app_name = app_var.get()
        functionalities_page(root, config, app_name)
    
    start_button = tk.Button(root, text="Start", command=go_to_functionalities)
    start_button.pack(pady=10)

def functionalities_page(root, config, app_name):
    for widget in root.winfo_children():
        widget.destroy()
    
    root.geometry('300x200')
    functionalities = config[app_name]['functionalitati']
    script_path = config[app_name]['script']
    
    tk.Label(root, text=f"Aplicație: {app_name}").pack(pady=10)
    
    def run_analysis(func_code):
        extra_args = []
        if func_code in ["1", "2", "3", "4"]:
            input_file = simpledialog.askstring("Input", "Introduceti numele fisierului pe care doriti sa il modificati:")
            if not input_file:
                messagebox.showwarning("Avertisment", "Nume fisier invalid!")
                return
            
            extra_args.append(input_file)
            
            if func_code == "1":
                output_file = "output_bw.png"
                extra_args.append(output_file)
            
            elif func_code == "2":
                dim1 = simpledialog.askstring("Input", "Introduceti latimea:")
                dim2 = simpledialog.askstring("Input", "Introduceti lungimea:")
                if not (dim1 and dim2):
                    messagebox.showwarning("Avertisment", "Dimensiuni invalide!")
                    return
                output_file = "output_resized.png"
                extra_args.append(output_file)
                extra_args.append(dim1)
                extra_args.append(dim2)
            
            elif func_code == "3":
                dir = simpledialog.askstring("Input", "Introduceti directia de rotatie (stanga/dreapta):")
                grad = simpledialog.askstring("Input", "Introduceti gradul de rotatie (1-180):")
                if not (dir and grad):
                    messagebox.showwarning("Avertisment", "Directie sau grad invalid!")
                    return
                output_file = "output_rotated.png"
                extra_args.append(output_file)
                extra_args.append(dir)
                extra_args.append(grad)
            
            elif func_code == "4":
                text = simpledialog.askstring("Input", "Introduceti textul pe care doriti sa ai adaugati:")
                if not text:
                    messagebox.showwarning("Avertisment", "Text invalid!")
                    return
                output_file = "output_text.png"
                extra_args.append(output_file)
                extra_args.append(text)
        
        output_window = tk.Toplevel(root)
        output_window.title("Output")
        output_text = Text(output_window, wrap=tk.WORD, height=20, width=50)
        output_text.pack(padx=10, pady=10, fill=tk.BOTH, expand=True)
        
        run_bash_script(script_path, func_code, extra_args, output_widget=output_text)
    
    for func_name, func_code in functionalities.items():
        button = tk.Button(root, text=func_name, command=lambda f=func_code: run_analysis(f))
        button.pack(pady=5)

if __name__ == "__main__":
    root = tk.Tk()
    root.title("Analiză Aplicatie")
    start_page(root, app_config)
    root.mainloop()
