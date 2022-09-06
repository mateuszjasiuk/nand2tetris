(def ignore-line-exp '{:comment-exp (sequence :s* (set "//")) 
                       :empty-line -1
                       :main (choice :comment-exp :empty-line)})
(defn read-from-file
  "Reads lines from file. Trims whitespace. Ignores //-comments."
  [file-path]
  (with [fl (file/open file-path)]
    (var lines @[])
    (loop [line :iterate (file/read fl :line)]
      (let [trimmed-line (string/trim line)]
        (if-not (peg/match ignore-line-exp trimmed-line)
          (array/push lines trimmed-line))))
    lines))


(def a-command-exp
  ~{:main (sequence :s* "@" :w+)})

(defn get-symbol [a-or-l-command]
  (peg/replace-all ~(choice "@" "(" ")") "" a-or-l-command))

(defn get-jump [c-command]
  (peg/replace ~(choice (thru ";") (thru -1)) "" c-command))

(defn get-dest [c-command]
  (peg/replace ~(choice (sequence "=" (thru -1))
                        (sequence ";" (thru -1))) "" c-command))

(defn get-comp [c-command]
  (peg/replace-all ~(choice (thru "=") (sequence ";" (thru -1))) "" c-command))

(comment
  (get-jump "A=D;JGT")
  (get-symbol "@ASD")
  (get-dest "A;JGT")
  (get-comp "A=D;JGT"))

(def c-command 
  '{:dest (choice "A" "D" "M")
    :comp (choice "0" "1" "-1" "!D" "!A" "-D" "-A"
                  "D+1" "A+1" "D-1" "A-1" "D+A" "D-A"
                  "A-D" "D&A" "D | A" "!M" "-M" "M+1"
                  "M-1" "D+M" "D-M" "M-D" "D&M" "D | M"
                  # Single register at the end
                  "D" "A" "M")
    :jmp (choice "JGT" "JEQ" "JGE" "JLT" "JNE" "JLE" "JMP")
    :main (sequence :s* (choice
                          (sequence :dest "=" :comp -1)
                          (sequence :comp ";" :jmp -1)
                          (sequence :dest "=" :comp ";" :jmp -1)))})

(def l-command '{:main (sequence "(" :w+ ")")})

(def dest-binary 
  @{"M" "001"
    "D" "010"
    "MD" "011"
    "A" "100"
    "AM" "101"
    "AD" "110"
    "AMD" "111"})

(def jmp-binary 
  @{"JGT" "001"
    "JEQ" "010"
    "JGE" "011"
    "JLT" "100"
    "JNE" "101"
    "JLE" "110"
    "JMP" "111"})

(def comp-binary
  @{"0" "0101010"
    "1" "0111111"
    "-1" "0111010"
    "D" "0001100"
    "A" "0110000"
    "!D" "0001101"
    "!A" "0110001"
    "-D" "0001111"
    "-A" "0110011"
    "D+1" "0011111"
    "A+1" "0110111"
    "D-1" "0001110"
    "A-1" "0110010"
    "D+A" "0000010"
    "D-A" "0010011"
    "A-D" "0000111"
    "D&A" "0000000"
    "D | A" "0010101"
    "M" "1110000"
    "!M" "1110001"
    "-M" "1110011"
    "M+1" "1110111"
    "M-1" "1110010"
    "D+M" "1000010"
    "D-M" "1010011"
    "M-D" "1000111"
    "D&M" "1000000"
    "D | M" "1010101"})

(defn print8bit-binary [number]
  (let [buf (reverse (range 16))]
    (->> buf
         (map (fn [v] 
           (->> v 
               (brshift number)
               (band 1)
               string)
           ))
         (string/join))))

(defn symbol-to-val [sym] (scan-number sym))

(defn compose-a-command [line]
  (let [s (get-symbol line)
        s-val (symbol-to-val s)
        s-val-binary (print8bit-binary s-val)]
    s-val-binary))

(defn- buffer->string [buf]
  (string/join (map string/from-bytes buf)))

(defn compose-c-command [line]
  (let [c (-> line get-comp buffer->string)
        dest (-> line get-dest buffer->string)
        jmp (-> line get-jump buffer->string)]
  (string/join @["111" 
                 (get comp-binary c "1111111")
                 (get dest-binary dest "000")
                 (get jmp-binary jmp "00")])))

(defn command-type [line]
  (cond 
    (peg/match a-command-exp line) (compose-a-command line)
    (peg/match c-command line) (compose-c-command line)
    (peg/match l-command line) @{:l-command (get-symbol line)}))
 

(let [lines (read-from-file "./add/Add.asm")]
  (map command-type lines))


