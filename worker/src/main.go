package main

import (
	"context"
	"crypto/tls"
	"database/sql"
	"encoding/json"
	"fmt"
	"github.com/go-redis/redis/v8"
	_ "github.com/lib/pq"
	"os"
	"time"
)

var (
	ctx = context.Background()
	rdb *redis.Client
	db  *sql.DB
	err error
)

type Vote struct {
	Vote    string `json:"vote"`
	VoterID string `json:"voter_id"`
}

func connectToDB() {

	ctx = context.Background()

	// Redis
	redis_url         := "redis://redis:6379"
  if r_url := os.Getenv("REDIS_URL"); r_url != "" {
    redis_url = r_url
  }
	fmt.Println("looping trying to connect to redis")
	for {
		time.Sleep(1 * time.Second)

		opt, err := redis.ParseURL(redis_url)
		if err != nil {
			panic(err)
		}

		// set InsecureSkipVerify to true if secure connection 
		if opt.TLSConfig != nil {
			fmt.Println("Connection is secured (rediss) => do not verify server cert (this is a temporary setting only)")
			opt.TLSConfig = &tls.Config{
				InsecureSkipVerify: true,
			}
		}

		rdb = redis.NewClient(opt)

		// Ping the Redis server to check the connection
		if err = rdb.Ping(ctx).Err(); err != nil {
			fmt.Println("Waiting for Redis " + err.Error())
			continue
		}
		fmt.Println("->  Connected to Redis !")
		break
	}

	// Postgres
 	host     := "db"
	port     := 5432
	user     := "postgres"
	pass     := "postgres"
	database := "postgres"
	pg_url   := fmt.Sprintf("postgres://%s:%s@%s:%d/%s?sslmode=disable", user, pass, host, port, database)

	// Use postgres connection string if it's provided
	if p_url := os.Getenv("POSTGRES_URL"); p_url != "" {
		pg_url = p_url
		fmt.Println(pg_url)
  } else {
		// If connection string if not provided, build a new one from username and password
		if pg_user := os.Getenv("POSTGRES_USER"); pg_user != "" {
			user = pg_user
		}

		if pg_password := os.Getenv("POSTGRES_PASSWORD"); pg_password != "" {
			pass = pg_password
		}

		// Standard format of connection string
		pg_url = fmt.Sprintf("postgres://%s:%s@%s:%d/%s?sslmode=disable", user, pass, host, port, database)
	}

	// Connect to database
	fmt.Println("looping trying to connect to postgres")
	for {
		time.Sleep(1 * time.Second)

		db, err = sql.Open("postgres", pg_url)
		if err != nil {
			fmt.Println(err)
			continue
		}

		// Check if the connection was successful
		err = db.Ping()
		if err != nil {
			fmt.Println(err)
			continue
		}

		fmt.Println("-> connected to Postgres !")
		break
	}

	// Make sure "votes" table exists in Postgres
	createTableStmt := `CREATE TABLE IF NOT EXISTS votes (id VARCHAR(255) NOT NULL UNIQUE, vote VARCHAR(255) NOT NULL)`
	_, err = db.Exec(createTableStmt)
	if err != nil {
		fmt.Println(err)
	}
}

func main() {
	// Init databases connection
	connectToDB()

	// Continuously get votes from Redis and add (or update) them into Postgres
	for {
		time.Sleep(400 * time.Millisecond)

		handleVotes(rdb, ctx, db)
	}
}

func handleVotes(rdb *redis.Client, ctx context.Context, db *sql.DB) {
	// Get vote from Redis
	result, err := rdb.BLPop(ctx, 0, "votes").Result()
	if err != nil {
		fmt.Println(err)
		return
	}

	// Convert retrieved string into json
	voteData := result[1]
	var vote Vote
	err = json.Unmarshal([]byte(voteData), &vote)
	if err != nil {
		fmt.Println(err)
		return
	}

	// Insert or update vote in Postgres
	upsertStmt := `INSERT INTO votes(id,vote) VALUES($1, $2) ON CONFLICT ON CONSTRAINT votes_id_key DO UPDATE SET vote = $2 WHERE votes.id=$1`
	_, e := db.Exec(upsertStmt, vote.VoterID, vote.Vote)
	if e != nil {
		fmt.Println(e)
		return
	}
	fmt.Printf("Vote from %s set to %s\n", vote.VoterID, vote.Vote)
}
