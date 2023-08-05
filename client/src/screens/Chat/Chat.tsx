import styles from "./Chat.module.css";
import useWebsockets from "../../hooks/useWebsocket";
import Cookies from "js-cookie";
import { useEffect, useMemo, useState } from "react";
import { Link, useParams } from "react-router-dom";
import clsx from "clsx";
import {
  ArrowLongRightIcon,
  ArrowSmallRightIcon,
  ChatBubbleLeftRightIcon,
  HomeIcon,
  PaperAirplaneIcon,
  PlusCircleIcon,
} from "@heroicons/react/24/outline";
import useDimensions from "react-cool-dimensions";
import { HashtagIcon } from "@heroicons/react/20/solid";

const Chat = () => {
  const params = useParams<{ id: string }>();

  const { observe, height } = useDimensions();


  return (
    <>
      <h1 className={styles.header}>Chat</h1>
      <main className={styles.root}>
        <div className={styles.rooms}>
          <h2 className={styles.roomHeader}>
            <div>
              <HomeIcon width="32px" /> <span>Rooms</span>
            </div>
            <PlusCircleIcon width="32px" />
          </h2>
          {list.map((room) => (
            <Link
              to={`${room.id}`}
              className={clsx(styles.roomItem, room.id == params.id && styles.active)}
              key={room.id}
            >
              <h3>
                <HashtagIcon width="24px" /> {room.name}
                <ArrowSmallRightIcon width="24px" />
              </h3>
              <p>{room.description}</p>
            </Link>
          ))}
        </div>
        <div className={styles.window}>
          {currentRoom?.name && (
            <h2 className={styles.windowHeader}>
              <div>
                <ChatBubbleLeftRightIcon width="32px" /> {currentRoom.name}
              </div>
              {currentRoom.event && (
                <Link to={`/events/${currentRoom.event?.id}`}>
                  {`This chat is linked to an Event: ${currentRoom.event.title} `}
                  <ArrowLongRightIcon width="24px" />
                </Link>
              )}
            </h2>
          )}
          <div ref={observe} className={styles.chatList} style={{ height: height }}>
            <div className={styles.chatContent}>
              {messages.map((message) => (
                <div className={styles.message} key={message.id}>
                  <span>{message.username}</span>
                  <div className={styles.messageContent}>
                    <p>{message.content}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
          <form
            className={styles.inputForm}
            onSubmit={(e) => {
              e.preventDefault();
              const input = document.getElementById("message") as HTMLInputElement;
              channel?.push("shout", { content: input.value });
              input.value = "";
            }}
          >
            <input id="message" className={styles.input} placeholder="Enter a message..." />
            <button title="Send a chat message" className={styles.submit} type="submit">
              <PaperAirplaneIcon width="24px" />
            </button>
          </form>
        </div>
        {/* <div className={styles.list}>
          <h2>
            <div>
              <UserCircleIcon width="32px" /> <span>People</span>
            </div>
          </h2>
          {currentRoom?.users &&
            currentRoom.users.map((user: any) => (
              <div key={user.id}>
                {user.firstName} {user.lastName}
              </div>
            ))}
        </div> */}
      </main>
    </>
  );
};

export default Chat;
