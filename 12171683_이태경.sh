#! /bin/bash

Exit="N"
echo "----------------------------------------"
echo "User Name: 이태경"
echo "Student Number: 12171683"
echo "[ MENU ]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
echo "2. Get the data of action genre movies from 'u.item'"
echo "3. Get the average 'rating’ of the movie identified by specific 'movie id' from 'u.data'"
echo "4. Delete the 'IMDb URL' from 'u.item'"
echo "5. Get the data about users from 'u.user'"
echo "6. Modify the format of 'release date' in 'u.item'"
echo "7. Get ::the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated by users with'age' between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"
echo "----------------------------------------"
until [ "${Exit}" == "Y" ]; do
    read -p "Enter your choice [ 1-9 ] " option
    case ${option} in
   1)
read -p "Please enter 'movie id'(1~1682):" movie_id
echo ""

awk -F '|' '$1 == '$movie_id' { print $0 }' ./u.item
;;

2)
read -p "Do you want to get the data of ‘action’ genre movies from 'u.item’?(y/n):" c
echo ""
if [ "${c}" = "y" ]; then
temp_file=$(mktemp)
awk -F '|' '$7 == 1 { print $1, $2 }' u.item > "$temp_file"
head -n 10 "$temp_file"
rm "$temp_file"
fi
;;

3)
read -p "Please enter the 'movie id’(1~1682):" movie_id
echo ""
total_rating=0
num_user=0

while IFS=$'\t' read -r user_id movie_ids rating timestamp; do
	if [ "$movie_id" == "$movie_ids" ]; then
		total_rating=$((total_rating + rating))
		num_user=$((num_user + 1))
	fi
done < u.data

echo $movie_id $total_rating $num_user | awk '{printf "average rating of %s: %.5f", $1, ($2 / $3 + 0.000005)}'
;;


4)
read -p "Do you want to delete the ‘IMDb URL’ from ‘u.item’?(y/n):" c
echo ""
if [ "${c}" = "y" ]; then
sed -e 's/http[^|]*|//g' u.item | head -n 10
fi
;;


5)
read -p "Do you want to get the data about users from ‘u.user’?(y/n):" c
echo ""
if [ "${c}" = "y" ]; then
head -n 10 u.user | while IFS='|' read -r user_id age gender occupation zip_code; do
	if [ "$gender" == "M" ]; then
		gender="male"
	elif [ "$gender" == "F" ]; then
		gender="female"
	fi
	result="user $user_id is $age years old $gender $occupation"
	echo "$result"
done
fi
;;


6)
read -p "Do you want to Modify the format of 'release data' in 'u.item'?(y/n):" c
echo ""
convert_month() {
case $1 in
    "Jan") echo "01";;
    "Feb") echo "02";;
    "Mar") echo "03";;
    Apr) echo "04";;
    May) echo "05";;
    Jun) echo "06";;
    Jul) echo "07";;
    Aug) echo "08";;
    Sep) echo "09";;
    Oct) echo "10";;
    Nov) echo "11";;
    Dec) echo "12";;
    *) echo "00";;
  esac
}
if [ "${c}" = "y" ]; then
	sed -E 's/([0-9]{2})-([A-Za-z]{3})-([0-9]{4})/\3'$(convert_month "$\2")'\1/' u.item | tail -n 10
fi
;;

7)
read -p "Please enter the ‘user id’(1~943):" user_id
echo ""
movie_list=$(awk -v user_id="$user_id" -F '\t' '$1 == user_id { print $2 }' u.data)
sort_movie_list=$(echo "$movie_list" | sort -n)
for movie_id in $sort_movie_list; do
	echo -n "$movie_id |"
done

echo ""
echo ""

sorted_movie_list=$(echo "$sort_movie_list" | head -n 10 )

for movie_id in $sorted_movie_list; do
	movie_name=$(awk -v movie_id="$movie_id" -F '|' '$1 == movie_id { print $2 }' u.item)
	echo "$movie_id | $movie_name"
done
;;

8)

read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n):" c
echo "" 
if [ "${c}" = "y" ]; then
user_ids=$(awk -F '|' '$2 >= 20 && $2 <= 29 && $4 == "programmer" { print $1 }' u.user)

awk -F '\t' -v user_ids="$user_ids" '
BEGIN { split(user_ids, users, " "); }
{
  if ($1 in users) {
    movie_ratings[$2] += $3;
    movie_counts[$2] += 1;
  }
}
END {
  for (movie_id in movie_ratings) {
    if (movie_counts[movie_id] > 0) {
      avg_rating = movie_ratings[movie_id] / movie_counts[movie_id];
      printf("%d %.5g \n", movie_id, avg_rating);
    }
  }
}' u.data
fi
;;

    9)
        echo "Bye!"
        Exit="Y"
        ;;
    esac
done
