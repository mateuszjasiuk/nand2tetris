(def ignore-line-exp ~{:comment-exp (sequence :s* (set "//")) 
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


(def a-command 
  '{:main (sequence :s* "@" :w+)})

(def c-command 
  '{:place (choice "A" "D" "M")
    :calc (choice "0" "1" "-1" "!D" "!A" "-D" "-A"
                  "D+1" "A+1" "D-1" "A-1" "D+A" "D-A"
                  "A-D" "D&A" "D | A" "!M" "-M" "M+1"
                  "M-1" "D+M" "D-M" "M-D" "D&M" "D | M"
                  # Single register at the end
                  "D" "A" "M")
    :jmp (choice "JGT" "JEQ" "JGE" "JLT" "JNE" "JLE" "JMP")
    :main (sequence :s* (choice
                          (sequence :place "=" :calc -1)
                          (sequence :calc ";" :jmp -1)
                          (sequence :place "=" :calc ";" :jmp -1)))})

(def l-command '{:main (sequence "(" :w+ ")")})

(defn command-type [line]
  (pp line)
  (cond 
    (peg/match a-command line) :a-command
    (peg/match c-command line) :c-command
    (peg/match l-command line) :l-command))
 

(let [lines (read-from-file "./add/Add.asm")]
  (map command-type lines))


